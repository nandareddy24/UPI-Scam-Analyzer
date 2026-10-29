import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/scan_result.dart';

/// Stores each analyzer run under /users/{uid}/scans/{auto-id}
/// so every user only ever sees their own history.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _scansRef(String uid) =>
      _db.collection('users').doc(uid).collection('scans');

  Future<void> saveScan(String uid, ScanResult result) async {
    try {
      await _scansRef(uid).add(result.toMap());
    } catch (e) {
      // Non-fatal catch to ensure Firestore network delays never freeze UI
      print('Firestore saveScan error: $e');
    }
  }

  Stream<List<ScanResult>> watchHistory(String uid) {
    return _scansRef(uid).snapshots().map((snap) {
      final results = <ScanResult>[];
      for (final doc in snap.docs) {
        try {
          results.add(ScanResult.fromMap(doc.data(), id: doc.id));
        } catch (e) {
          print('Firestore parse error for ${doc.id}: $e');
        }
      }
      // Sort newest first by timestamp safely in memory
      results.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      return results;
    });
  }

  Future<void> deleteScan(String uid, String scanId) async {
    try {
      await _scansRef(uid).doc(scanId).delete();
    } catch (e) {
      print('Firestore deleteScan error: $e');
    }
  }

  Future<void> clearAllHistory(String uid) async {
    try {
      final snap = await _scansRef(uid).get();
      final batch = _db.batch();
      for (final doc in snap.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      print('Firestore clearAllHistory error: $e');
    }
  }
}
