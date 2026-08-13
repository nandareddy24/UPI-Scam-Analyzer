import 'dart:convert';
import '../core/network/api_client.dart';
import '../core/storage/secure_storage.dart';
import '../models/auth_response.dart';
import '../models/user.dart';

class AuthRepository {
  final ApiClient apiClient;
  final SecureStorageService storageService;

  AuthRepository({required this.apiClient, required this.storageService});

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/auth/login',
        data: {'email': email, 'password': password},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        await storageService.saveToken(authResponse.token!);
      }
      if (authResponse.user != null) {
        await storageService.saveUserData(jsonEncode(authResponse.user!.toJson()));
      }
      return authResponse;
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<AuthResponse> register(String name, String email, String password) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<AuthResponse> verifyRegistration(String email, String otp) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/auth/verify-registration',
        data: {'email': email, 'otp': otp},
      );
      final authResponse = AuthResponse.fromJson(response.data);
      if (authResponse.token != null) {
        await storageService.saveToken(authResponse.token!);
      }
      if (authResponse.user != null) {
        await storageService.saveUserData(jsonEncode(authResponse.user!.toJson()));
      }
      return authResponse;
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<AuthResponse> forgotPassword(String email) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/auth/forgot-password',
        data: {'email': email},
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<AuthResponse> resendOtp(String email, String purpose) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/auth/resend-otp',
        data: {'email': email, 'purpose': purpose},
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<AuthResponse> resetPassword(String email, String otp, String newPassword) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/auth/reset-password',
        data: {'email': email, 'otp': otp, 'new_password': newPassword},
      );
      return AuthResponse.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await apiClient.dio.get('/api/v1/auth/me');
      if (response.data != null && response.data['user'] != null) {
        final user = UserModel.fromJson(response.data['user']);
        await storageService.saveUserData(jsonEncode(user.toJson()));
        return user;
      }
      return null;
    } catch (e) {
      // Fallback to local stored user if offline
      final storedJson = await storageService.getUserData();
      if (storedJson != null) {
        return UserModel.fromJson(jsonDecode(storedJson));
      }
      return null;
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.dio.post('/api/v1/auth/logout');
    } catch (_) {}
    await storageService.clearAll();
  }
}
