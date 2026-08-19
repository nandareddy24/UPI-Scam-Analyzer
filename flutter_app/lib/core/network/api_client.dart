import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../storage/secure_storage.dart';

class ApiClient {
  late Dio dio;
  final SecureStorageService storageService;

  ApiClient({required this.storageService}) {
    _initDio();
  }

  void _initDio() {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          options.baseUrl = ApiConfig.baseUrl;
          final token = await storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            await storageService.clearAll();
          }
          return handler.next(error);
        },
      ),
    );
  }

  void updateBaseUrl() {
    dio.options.baseUrl = ApiConfig.baseUrl;
  }

  static String getErrorMessage(dynamic error) {
    if (error is DioException) {
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError) {
        return 'Online AI analysis unavailable. Please check your connection or backend server URL.';
      }
      if (error.response?.data != null && error.response?.data is Map) {
        final message = error.response?.data['message'] ?? error.response?.data['error'];
        if (message != null && message.toString().isNotEmpty) {
          return message.toString();
        }
      }
      if (error.response?.statusCode != null) {
        return 'Server error (${error.response!.statusCode}). Please try again later.';
      }
      return 'Network request failed. Please check backend configuration.';
    }
    return error.toString();
  }
}
