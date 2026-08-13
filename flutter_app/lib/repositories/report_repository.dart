import '../core/network/api_client.dart';

class ReportRepository {
  final ApiClient apiClient;

  ReportRepository({required this.apiClient});

  Future<void> submitReport({
    required String type,
    required String inputData,
    required String reason,
    String? proofData,
  }) async {
    try {
      await apiClient.dio.post(
        '/api/v1/reports',
        data: {
          'type': type,
          'input_data': inputData,
          'reason': reason,
          if (proofData != null) 'proof_data': proofData,
        },
      );
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }
}
