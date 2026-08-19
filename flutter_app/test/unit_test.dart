import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_app/models/scan_result.dart';

void main() {
  group('UPI & URL Format Validation Tests', () {
    test('Validates standard UPI VPA handles', () {
      final upiRegex = RegExp(r'^[\w.-]+@[\w.-]+$');
      expect(upiRegex.hasMatch('test@upi'), isTrue);
      expect(upiRegex.hasMatch('merchant@paytm'), isTrue);
      expect(upiRegex.hasMatch('john.doe@okicici'), isTrue);
      expect(upiRegex.hasMatch('invalid_upi_handle'), isFalse);
      expect(upiRegex.hasMatch('@missing_user'), isFalse);
    });

    test('Validates URL http/https formatting', () {
      expect('https://example.com'.startsWith('http'), isTrue);
      expect('http://test-bank.net'.startsWith('http'), isTrue);
    });

    test('Validates Android APK extension', () {
      expect('fake_sbi.apk'.toLowerCase().endsWith('.apk'), isTrue);
      expect('malware.exe'.toLowerCase().endsWith('.apk'), isFalse);
    });
  });

  group('Risk Score Level Classification Tests', () {
    test('Maps raw score 0 to SAFE (0-40 range)', () {
      final score = ScanResult.calculateDisplayScore(0, 'Safe');
      expect(score >= 0 && score <= 40, isTrue);
    });

    test('Maps raw score 5 to WARNING (41-70 range)', () {
      final score = ScanResult.calculateDisplayScore(5, 'Warning');
      expect(score >= 41 && score <= 70, isTrue);
    });

    test('Maps raw score 9 to DANGEROUS (71-100 range)', () {
      final score = ScanResult.calculateDisplayScore(9, 'Dangerous');
      expect(score >= 71 && score <= 100, isTrue);
    });
  });

  group('ScanResult JSON Deserialization Tests', () {
    test('Parses Flask API JSON response correctly', () {
      final json = {
        'status': 'success',
        'score': 8,
        'result': 'Dangerous',
        'reason': 'Matched Global Blacklist Record, Contains suspicious keywords',
        'confidence': 95,
        'advice': 'Do not send money to this UPI ID.',
        'input_data': 'scammer@upi',
      };

      final scanResult = ScanResult.fromJson(json, defaultType: 'UPI');
      expect(scanResult.result, equals('Dangerous'));
      expect(scanResult.inputData, equals('scammer@upi'));
      expect(scanResult.displayScore >= 75, isTrue);
      expect(scanResult.reasonList.length, equals(2));
    });

    test('Parses Flask APK Scanner response correctly', () {
      final apkJson = {
        'status': 'success',
        'score': 9,
        'result': 'Dangerous',
        'reason': 'Filename contains fake banking/scam keywords: sbi | SMS Interception permission requested',
        'confidence': 98,
        'advice': 'CRITICAL MALWARE RISK: Do NOT install or open this APK file.',
        'apk_details': {
          'filename': 'sbi_rewards_update.apk',
          'size_mb': 4.5,
          'sha256': 'a1b2c3d4e5f67890',
          'permissions': ['SMS Interception permission requested']
        }
      };

      final scanResult = ScanResult.fromJson(apkJson, defaultType: 'APK', defaultInput: 'sbi_rewards_update.apk');
      expect(scanResult.result, equals('Dangerous'));
      expect(scanResult.type, equals('APK'));
      expect(scanResult.inputData, equals('sbi_rewards_update.apk'));
      expect(scanResult.displayScore >= 75, isTrue);
    });
  });

  group('QR Code Payment Payload Parser Tests', () {
    test('Parses upi://pay query parameters', () {
      final qrString = 'upi://pay?pa=test@upi&pn=TestMerchant&am=500&cu=INR&tn=Payment';
      final uri = Uri.parse(qrString);
      expect(uri.scheme, equals('upi'));
      expect(uri.host, equals('pay'));
      expect(uri.queryParameters['pa'], equals('test@upi'));
      expect(uri.queryParameters['pn'], equals('TestMerchant'));
      expect(uri.queryParameters['am'], equals('500'));
    });
  });
}
