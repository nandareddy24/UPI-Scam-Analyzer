import 'package:flutter_test/flutter_test.dart';
import 'package:upi_scam_analyzer/services/analyzer_service.dart';
import 'package:upi_scam_analyzer/models/scan_result.dart';

void main() {
  group('AnalyzerService Scam Detection Tests', () {
    test('Detects high risk scam messages', () {
      final result = AnalyzerService.analyzeMessage('URGENT: Your KYC expired. Share your OTP now to avoid block.');
      expect(result.riskLevel, RiskLevel.high);
      expect(result.score, greaterThanOrEqualTo(12));
      expect(result.reasons, isNotEmpty);
    });

    test('Identifies suspicious UPI ID handles', () {
      final result = AnalyzerService.analyzeUpiId('refund-helpdesk@suspiciousbank');
      expect(result.riskLevel, RiskLevel.high);
      expect(result.reasons.any((r) => r.contains('refund')), isTrue);
    });

    test('Flags suspicious phishing URLs', () {
      final result = AnalyzerService.analyzeUrl('http://192.168.1.1/login-bank-account');
      expect(result.riskLevel, RiskLevel.high);
      expect(result.reasons.any((r) => r.contains('IP address')), isTrue);
    });

    test('Validates clean standard UPI ID', () {
      final result = AnalyzerService.analyzeUpiId('john.doe@okaxis');
      expect(result.riskLevel, RiskLevel.low);
    });
  });
}
