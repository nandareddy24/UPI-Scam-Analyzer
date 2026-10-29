import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scan_result.dart';

/// Hybrid History Service:
/// 1. Instant local persistence (works 100% offline, zero network delay, zero permission crash)
/// 2. Background Cloud Firestore synchronization when online
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;

  FirestoreService._internal() {
    _loadLocalCache();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // In-memory list of scans (newest first)
  static final List<ScanResult> _inMemoryCache = [];
  static final StreamController<List<ScanResult>> _streamController =
      StreamController<List<ScanResult>>.broadcast();

  static bool _initialized = false;

  /// Synchronous access to current cached scans
  List<ScanResult> get currentHistory => List.unmodifiable(_inMemoryCache);

  CollectionReference<Map<String, dynamic>> _scansRef(String uid) =>
      _db.collection('users').doc(uid).collection('scans');

  File? _getLocalHistoryFile() {
    try {
      final dir = Directory.systemTemp;
      return File('${dir.path}/upi_scam_history_v2.json');
    } catch (_) {
      return null;
    }
  }

  Future<void> _loadLocalCache() async {
    if (_initialized) return;
    _initialized = true;

    try {
      final file = _getLocalHistoryFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        if (content.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(content);
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _inMemoryCache.add(ScanResult.fromMap(item));
            }
          }
        }
      }
    } catch (e) {
      print('[History] Local cache read error: $e');
    }

    // If cache is still empty, pre-populate with default initial sample scans
    if (_inMemoryCache.isEmpty) {
      _seedInitialSampleScans();
    }

    _sortAndEmit();
  }

  void _seedInitialSampleScans() {
    final now = DateTime.now();
    _inMemoryCache.addAll([
      ScanResult(
        id: 'sample_01',
        type: 'upi',
        input: 'refund.claim@fakebank',
        riskLevel: RiskLevel.high,
        score: 22,
        confidence: 98,
        verdictTitle: 'Critical Fraud Handle Flagged',
        reasons: [
          'Known phishing handle impersonating bank refund desk',
          'Absence of standard NPCI payment gateway verification',
        ],
        advice: 'Never approve collect requests or enter UPI PIN for receiving refunds.',
        timestamp: now.subtract(const Duration(hours: 1)),
      ),
      ScanResult(
        id: 'sample_02',
        type: 'url',
        input: 'http://sbi-kyc-verify-account.top/login',
        riskLevel: RiskLevel.high,
        score: 20,
        confidence: 96,
        verdictTitle: 'Phishing Domain Detected',
        reasons: [
          'Unregistered top-level domain (.top) mimicking State Bank of India',
          'Insecure cleartext HTTP protocol without SSL certificate',
        ],
        advice: 'Do NOT enter banking credentials or OTPs on this website.',
        timestamp: now.subtract(const Duration(hours: 3)),
      ),
      ScanResult(
        id: 'sample_03',
        type: 'message',
        input: 'Dear Customer, Rs 25,000 lottery won. Click bit.ly/win-upi to claim prize.',
        riskLevel: RiskLevel.medium,
        score: 9,
        confidence: 92,
        verdictTitle: 'Suspicious Lottery SMS',
        reasons: [
          'Unsolicited cash reward lottery pattern detected',
          'Contains shortened redirection URL link',
        ],
        advice: 'Exercise caution. Delete message and block unknown sender.',
        timestamp: now.subtract(const Duration(days: 1)),
      ),
    ]);
  }

  Future<void> _persistLocally() async {
    try {
      final file = _getLocalHistoryFile();
      if (file != null) {
        final listMap = _inMemoryCache.map((s) => s.toMap()).toList();
        await file.writeAsString(jsonEncode(listMap));
      }
    } catch (e) {
      print('[History] Failed to write local cache: $e');
    }
  }

  void _sortAndEmit() {
    _inMemoryCache.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    _streamController.add(List.unmodifiable(_inMemoryCache));
  }

  /// Save scan: writes immediately to local storage and attempts Firestore cloud sync
  Future<void> saveScan(String uid, ScanResult result) async {
    final scanWithId = result.id != null && result.id!.isNotEmpty
        ? result
        : result.copyWith(id: 'scan_${DateTime.now().millisecondsSinceEpoch}');

    // 1. Immediately store in local memory and disk
    _inMemoryCache.removeWhere((s) => s.id == scanWithId.id);
    _inMemoryCache.insert(0, scanWithId);
    _sortAndEmit();
    await _persistLocally();

    // 2. Background Cloud Firestore synchronization
    if (uid.isNotEmpty && uid != 'local_user') {
      try {
        await _scansRef(uid).doc(scanWithId.id).set(scanWithId.toMap());
      } catch (e) {
        // Non-fatal: if Firestore is offline or permission-denied, local copy is safe
        print('[History] Firestore sync skipped/failed: $e');
      }
    }
  }

  /// Reactive stream for HistoryScreen & Recent Scans
  Stream<List<ScanResult>> watchHistory(String uid) {
    _loadLocalCache();

    // If online with valid UID, attempt live Firestore listener without blocking
    if (uid.isNotEmpty && uid != 'local_user') {
      try {
        _scansRef(uid).snapshots().listen((snap) {
          bool updated = false;
          for (final doc in snap.docs) {
            final cloudItem = ScanResult.fromMap(doc.data(), id: doc.id);
            final existingIdx = _inMemoryCache.indexWhere((s) => s.id == cloudItem.id);
            if (existingIdx == -1) {
              _inMemoryCache.add(cloudItem);
              updated = true;
            }
          }
          if (updated) {
            _sortAndEmit();
            _persistLocally();
          }
        }, onError: (err) {
          print('[History] Cloud listener notice (offline fallback active): $err');
        });
      } catch (e) {
        print('[History] Could not attach cloud listener: $e');
      }
    }

    // Create a broadcast stream that immediately yields the current cache
    Stream<List<ScanResult>> combinedStream() async* {
      yield List.unmodifiable(_inMemoryCache);
      yield* _streamController.stream;
    }

    return combinedStream();
  }

  /// Delete single scan
  Future<void> deleteScan(String uid, String scanId) async {
    _inMemoryCache.removeWhere((s) => s.id == scanId);
    _sortAndEmit();
    await _persistLocally();

    if (uid.isNotEmpty && uid != 'local_user') {
      try {
        await _scansRef(uid).doc(scanId).delete();
      } catch (e) {
        print('[History] Firestore delete error: $e');
      }
    }
  }

  /// Clear all history
  Future<void> clearAllHistory(String uid) async {
    _inMemoryCache.clear();
    _sortAndEmit();
    await _persistLocally();

    if (uid.isNotEmpty && uid != 'local_user') {
      try {
        final snap = await _scansRef(uid).get();
        final batch = _db.batch();
        for (final doc in snap.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      } catch (e) {
        print('[History] Firestore clear error: $e');
      }
    }
  }
}
