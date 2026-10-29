import 'package:flutter_test/flutter_test.dart';
import 'package:upi_scam_analyzer/services/analyzer_service.dart';

void main() {
  test('App Services Initialization Test', () {
    final result = AnalyzerService.analyzeMessage('Test clean message');
    expect(result.type, equals('message'));
  });
}
