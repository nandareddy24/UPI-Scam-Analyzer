import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Talks to the Node/Express OTP server in `backend-otp-server/`.
/// Automatically discovers and connects to the reachable base URL across Web,
/// Android Emulator, Physical LAN Device, and Desktop.
class OtpApiService {
  static String? _resolvedBaseUrl;

  /// Candidate URLs depending on platform
  static List<String> get candidateUrls {
    if (kIsWeb) {
      final host = Uri.base.host;
      final portHost = (host.isNotEmpty && host != '0.0.0.0') ? host : 'localhost';
      return [
        'http://$portHost:4000',
        'http://localhost:4000',
        'http://127.0.0.1:4000',
        'http://172.20.143.80:4000',
      ];
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return [
          'http://10.0.2.2:4000',      // Android emulator loopback
          'http://172.20.143.80:4000', // Wi-Fi LAN IP
          'http://localhost:4000',
        ];
      case TargetPlatform.iOS:
        return [
          'http://localhost:4000',      // iOS simulator
          'http://172.20.143.80:4000', // Wi-Fi LAN IP
        ];
      default:
        return [
          'http://localhost:4000',
          'http://127.0.0.1:4000',
          'http://172.20.143.80:4000',
        ];
    }
  }

  static Future<ApiResult> sendOtp(String email) async {
    return _post('/api/send-otp', {'email': email});
  }

  static Future<ApiResult> verifyOtp(String email, String otp) async {
    return _post('/api/verify-otp', {'email': email, 'otp': otp});
  }

  static Future<ApiResult> _post(String path, Map<String, dynamic> body) async {
    // If we already resolved a working base URL, try it first
    if (_resolvedBaseUrl != null) {
      final res = await _attemptPost(_resolvedBaseUrl!, path, body, timeoutSec: 10);
      if (res != null) return res;
      // If it failed, reset and try all candidates
      _resolvedBaseUrl = null;
    }

    // Try all candidate URLs
    for (final base in candidateUrls) {
      final res = await _attemptPost(base, path, body, timeoutSec: 4);
      if (res != null) {
        _resolvedBaseUrl = base;
        return res;
      }
    }

    return ApiResult(
      success: false,
      message: 'Could not connect to the OTP server on port 4000. '
          'Please ensure the backend server is running in backend-otp-server/ '
          '(e.g. "npm start").',
    );
  }

  static Future<ApiResult?> _attemptPost(
    String baseUrl,
    String path,
    Map<String, dynamic> body, {
    int timeoutSec = 5,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(Duration(seconds: timeoutSec));

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return ApiResult(
        success: data['success'] == true,
        message: data['message']?.toString() ?? 'Server responded.',
      );
    } catch (_) {
      // Failed to connect to this candidate URL
      return null;
    }
  }
}

class ApiResult {
  final bool success;
  final String message;
  ApiResult({required this.success, required this.message});
}
