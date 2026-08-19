import '../core/network/api_client.dart';

class ReportRepository {
  final ApiClient apiClient;

  ReportRepository({required this.apiClient});

  Future<String> submitReport({
    required String type,
    required String inputData,
    required String reason,
    String? proofData,
  }) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/reports',
        data: {
          'type': type,
          'data': inputData,
          'reason': reason,
          'proof': proofData ?? '',
        },
      );
      return response.data['message'] ?? 'Scam report submitted successfully.';
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }
}
