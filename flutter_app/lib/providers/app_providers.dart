import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/config/api_config.dart';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/scan_result.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/scan_repository.dart';
import '../repositories/history_repository.dart';
import '../repositories/report_repository.dart';
import '../repositories/admin_repository.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(storageService: storage);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    apiClient: ref.watch(apiClientProvider),
    storageService: ref.watch(secureStorageProvider),
  );
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  return ScanRepository(apiClient: ref.watch(apiClientProvider));
});

final historyRepositoryProvider = Provider<HistoryRepository>((ref) {
  return HistoryRepository(apiClient: ref.watch(apiClientProvider));
});

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return ReportRepository(apiClient: ref.watch(apiClientProvider));
});

final adminRepositoryProvider = Provider<AdminRepository>((ref) {
  return AdminRepository(apiClient: ref.watch(apiClientProvider));
});

// Auth State Notifier
class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository authRepo;

  AuthNotifier(this.authRepo) : super(const AsyncValue.loading()) {
    checkAuth();
  }

  Future<void> checkAuth() async {
    state = const AsyncValue.loading();
    try {
      final user = await authRepo.getProfile();
      state = AsyncValue.data(user);
    } catch (e) {
      state = const AsyncValue.data(null);
    }
  }

  Future<void> setUser(UserModel? user) async {
    state = AsyncValue.data(user);
  }

  Future<void> logout() async {
    await authRepo.logout();
    state = const AsyncValue.data(null);
  }
}

final authStateProvider = StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});

// History State Notifier
class HistoryNotifier extends StateNotifier<AsyncValue<List<ScanResult>>> {
  final HistoryRepository historyRepo;

  HistoryNotifier(this.historyRepo) : super(const AsyncValue.loading()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    state = const AsyncValue.loading();
    try {
      final items = await historyRepo.getHistory();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteScan(String id) async {
    await historyRepo.deleteScan(id);
    await loadHistory();
  }

  Future<void> clearAll() async {
    await historyRepo.clearAll();
    await loadHistory();
  }
}

final historyStateProvider = StateNotifierProvider<HistoryNotifier, AsyncValue<List<ScanResult>>>((ref) {
  return HistoryNotifier(ref.watch(historyRepositoryProvider));
});

// Config & Server URL Provider
class BaseUrlNotifier extends StateNotifier<String> {
  final ApiClient apiClient;

  BaseUrlNotifier(this.apiClient) : super(ApiConfig.baseUrl);

  Future<void> updateUrl(String newUrl) async {
    await ApiConfig.setBaseUrl(newUrl);
    apiClient.updateBaseUrl();
    state = ApiConfig.baseUrl;
  }
}

final baseUrlProvider = StateNotifierProvider<BaseUrlNotifier, String>((ref) {
  return BaseUrlNotifier(ref.watch(apiClientProvider));
});

// Health check provider
final healthStatusProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final res = await client.dio.get('/api/v1/health');
    return res.data is Map<String, dynamic> ? res.data : {'status': 'ok'};
  } catch (e) {
    return {'status': 'offline', 'error': ApiClient.getErrorMessage(e)};
  }
});
