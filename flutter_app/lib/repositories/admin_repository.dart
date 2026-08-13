import '../core/network/api_client.dart';
import '../models/report.dart';
import '../models/blacklist_item.dart';

class AdminRepository {
  final ApiClient apiClient;

  AdminRepository({required this.apiClient});

  Future<List<ReportModel>> getReports() async {
    try {
      final response = await apiClient.dio.get('/api/v1/admin/reports');
      final List data = response.data is List ? response.data : (response.data['reports'] ?? []);
      return data.map((e) => ReportModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<void> approveReport(int id) async {
    try {
      await apiClient.dio.post('/api/v1/admin/reports/$id/approve');
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<void> rejectReport(int id) async {
    try {
      await apiClient.dio.post('/api/v1/admin/reports/$id/reject');
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<List<BlacklistItemModel>> getBlacklist() async {
    try {
      final response = await apiClient.dio.get('/api/v1/admin/blacklist');
      final List data = response.data is List ? response.data : (response.data['items'] ?? []);
      return data.map((e) => BlacklistItemModel.fromJson(e)).toList();
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<void> addBlacklist(String data, String type, String reason) async {
    try {
      await apiClient.dio.post(
        '/api/v1/admin/blacklist',
        data: {'data': data, 'type': type, 'reason': reason},
      );
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<void> deleteBlacklist(int id) async {
    try {
      await apiClient.dio.delete('/api/v1/admin/blacklist/$id');
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }
}
