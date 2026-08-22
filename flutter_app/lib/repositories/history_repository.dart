import '../core/network/api_client.dart';
import '../core/storage/local_history_service.dart';
import '../models/scan_result.dart';

class HistoryRepository {
  final ApiClient apiClient;

  HistoryRepository({required this.apiClient});

  Future<List<ScanResult>> getHistory() async {
    // 1. Load local scan history
    final localList = await LocalHistoryService.getHistory();

    // 2. Sync local unsynced scan items to backend if online and authenticated
    try {
      final token = await apiClient.storageService.getToken();
      if (token != null && token.isNotEmpty && localList.isNotEmpty) {
        final syncPayload = localList.map((e) => {
          'type': e.type,
          'input_data': e.inputData,
          'score': e.score,
          'result': e.result,
        }).toList();
        await apiClient.dio.post('/api/v1/scans/sync', data: {'items': syncPayload});
      }
    } catch (_) {
      // Ignore sync network errors silently
    }

    // 3. Fetch remote scan history from backend if available
    try {
      final response = await apiClient.dio.get('/api/v1/scans/history');
      final data = response.data;
      if (data != null && data['items'] is List) {
        final List remoteItems = data['items'];
        final remoteScans = remoteItems.map((e) {
          return ScanResult.fromJson(
            e as Map<String, dynamic>,
            defaultType: e['type'] ?? 'SCAN',
            defaultInput: e['data'] ?? '',
          );
        }).toList();

        // Combine local and remote without duplicates
        final Set<String> existingInputs = localList.map((e) => e.inputData.toLowerCase()).toSet();
        for (var remoteItem in remoteScans) {
          if (!existingInputs.contains(remoteItem.inputData.toLowerCase())) {
            localList.add(remoteItem);
          }
        }
      }
    } catch (_) {
      // Offline fallback: returns localList silently
    }

    localList.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return localList;
  }

  Future<void> deleteScan(String id) async {
    await LocalHistoryService.deleteScan(id);
  }

  Future<void> clearAll() async {
    await LocalHistoryService.clearHistory();
  }
}
