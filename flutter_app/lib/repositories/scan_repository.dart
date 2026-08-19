import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../core/storage/local_history_service.dart';
import '../models/scan_result.dart';

class ScanRepository {
  final ApiClient apiClient;

  ScanRepository({required this.apiClient});

  Future<ScanResult> scanUpi(String upiId) async {
    final cleanUpi = upiId.trim();
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/upi',
        data: {'upi': cleanUpi},
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'UPI',
        defaultInput: cleanUpi,
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      // Local fallback calculation if offline
      final offlineResult = _offlineUpiScan(cleanUpi);
      await LocalHistoryService.saveScan(offlineResult);
      return offlineResult;
    }
  }

  Future<ScanResult> scanPhone(String phone) async {
    final cleanPhone = phone.trim();
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/phone',
        data: {'phone': cleanPhone},
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'PHONE',
        defaultInput: cleanPhone,
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      final offlineResult = _offlinePhoneScan(cleanPhone);
      await LocalHistoryService.saveScan(offlineResult);
      return offlineResult;
    }
  }

  Future<ScanResult> scanSms(String message) async {
    final cleanSms = message.trim();
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/sms',
        data: {'sms': cleanSms},
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'SMS',
        defaultInput: cleanSms,
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      final offlineResult = _offlineSmsScan(cleanSms);
      await LocalHistoryService.saveScan(offlineResult);
      return offlineResult;
    }
  }

  Future<ScanResult> scanUrl(String url) async {
    final cleanUrl = url.trim();
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/url',
        data: {'url': cleanUrl},
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'URL',
        defaultInput: cleanUrl,
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      final offlineResult = _offlineUrlScan(cleanUrl);
      await LocalHistoryService.saveScan(offlineResult);
      return offlineResult;
    }
  }

  Future<ScanResult> scanQr(String payload) async {
    final cleanPayload = payload.trim();
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/qr',
        data: {'payload': cleanPayload},
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'QR',
        defaultInput: cleanPayload,
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      final offlineResult = _offlineUpiScan(cleanPayload);
      await LocalHistoryService.saveScan(offlineResult);
      return offlineResult;
    }
  }

  Future<ScanResult> scanImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'screenshot': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.dio.post(
        '/api/v1/scan/image',
        data: formData,
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'IMAGE',
        defaultInput: 'OCR Image Scan',
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<ScanResult> scanApk(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'apk': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.dio.post(
        '/api/v1/scan/apk',
        data: formData,
      );
      final result = ScanResult.fromJson(
        response.data,
        defaultType: 'APK',
        defaultInput: filePath.split('/').last.split('\\').last,
      );
      await LocalHistoryService.saveScan(result);
      return result;
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  // --- Local Offline Heuristic Rule Engines (Clearly Marked Offline) ---
  ScanResult _offlineUpiScan(String upi) {
    bool hasAt = upi.contains('@');
    int score = 0;
    List<String> reasons = ["Online AI analysis unavailable. Local basic format validation used."];

    if (!hasAt) {
      score += 5;
      reasons.add("Invalid handle format (missing '@' symbol)");
    }
    final lower = upi.toLowerCase();
    if (lower.contains('win') || lower.contains('free') || lower.contains('cash') || lower.contains('offer')) {
      score += 5;
      reasons.add("Contains suspicious offer keywords");
    }

    String verdict = score >= 8 ? "Dangerous" : (score >= 4 ? "Warning" : "Safe");
    int displayScore = ScanResult.calculateDisplayScore(score, verdict);

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'UPI',
      inputData: upi,
      rawScore: score,
      displayScore: displayScore,
      result: verdict,
      reason: reasons.join(' | '),
      confidence: 60,
      advice: 'Online ML model unavailable. Exercise caution before transferring money.',
    );
  }

  ScanResult _offlineUrlScan(String url) {
    final lower = url.toLowerCase();
    int score = 0;
    List<String> reasons = ["Online AI analysis unavailable. Local URL structure check applied."];

    if (!lower.startsWith('https://')) {
      score += 3;
      reasons.add("Unencrypted HTTP link (no SSL)");
    }
    if (lower.contains('bit.ly') || lower.contains('tinyurl') || lower.contains('is.gd')) {
      score += 5;
      reasons.add("Shortened URL service used");
    }
    if (lower.contains('login') || lower.contains('verify') || lower.contains('bank')) {
      score += 4;
      reasons.add("Suspicious banking/credential keywords");
    }

    String verdict = score >= 8 ? "Dangerous" : (score >= 4 ? "Warning" : "Safe");
    int displayScore = ScanResult.calculateDisplayScore(score, verdict);

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'URL',
      inputData: url,
      rawScore: score,
      displayScore: displayScore,
      result: verdict,
      reason: reasons.join(' | '),
      confidence: 60,
      advice: 'Online phishing classifier unavailable. Do not enter credentials on suspicious sites.',
    );
  }

  ScanResult _offlineSmsScan(String sms) {
    final lower = sms.toLowerCase();
    int score = 0;
    List<String> reasons = ["Online AI analysis unavailable. Local keyword rules applied."];

    if (lower.contains('http') || lower.contains('bit.ly')) {
      score += 4;
      reasons.add("Contains external web link");
    }
    if (lower.contains('rs') || lower.contains('₹') || lower.contains('credited') || lower.contains('win')) {
      score += 4;
      reasons.add("Money reward & transaction triggers");
    }

    String verdict = score >= 8 ? "Dangerous" : (score >= 4 ? "Warning" : "Safe");
    int displayScore = ScanResult.calculateDisplayScore(score, verdict);

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'SMS',
      inputData: sms,
      rawScore: score,
      displayScore: displayScore,
      result: verdict,
      reason: reasons.join(' | '),
      confidence: 60,
      advice: 'Online SMS model unavailable. Never share OTP or click links in text messages.',
    );
  }

  ScanResult _offlinePhoneScan(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    int score = digits.length == 10 ? 0 : 3;
    String verdict = score >= 3 ? "Warning" : "Safe";
    int displayScore = ScanResult.calculateDisplayScore(score, verdict);

    return ScanResult(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'PHONE',
      inputData: phone,
      rawScore: score,
      displayScore: displayScore,
      result: verdict,
      reason: 'Online database unavailable. Standard 10-digit number check.',
      confidence: 50,
      advice: 'Verify caller identity independently.',
    );
  }
}
