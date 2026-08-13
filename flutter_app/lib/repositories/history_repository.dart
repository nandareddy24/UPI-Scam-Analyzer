import '../core/network/api_client.dart';
import '../models/history_item.dart';

class HistoryRepository {
  final ApiClient apiClient;

  HistoryRepository({required this.apiClient});

  Future<List<HistoryItemModel>> getHistory() async {
    try {
      final response = await apiClient.dio.get('/api/v1/scans/history');
      final data = response.data;
      if (data != null) {
        final List itemsJson = data['scans'] ?? data['items'] ?? (data is List ? data : []);
        return itemsJson.map((e) => HistoryItemModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }
}
