import 'package:dio/dio.dart';
import '../core/network/api_client.dart';
import '../models/scan_result.dart';

class ScanRepository {
  final ApiClient apiClient;

  ScanRepository({required this.apiClient});

  Future<ScanResultModel> scanUpi(String upiId) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/upi',
        data: {'upi_id': upiId},
      );
      return ScanResultModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<ScanResultModel> scanPhone(String phone) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/phone',
        data: {'phone': phone},
      );
      return ScanResultModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<ScanResultModel> scanSms(String message) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/sms',
        data: {'message': message},
      );
      return ScanResultModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<ScanResultModel> scanUrl(String url) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/url',
        data: {'url': url},
      );
      return ScanResultModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<ScanResultModel> scanImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });
      final response = await apiClient.dio.post(
        '/api/v1/scan/image',
        data: formData,
      );
      return ScanResultModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }

  Future<ScanResultModel> scanQr(String qrData) async {
    try {
      final response = await apiClient.dio.post(
        '/api/v1/scan/qr',
        data: {'qr_data': qrData},
      );
      return ScanResultModel.fromJson(response.data);
    } catch (e) {
      throw ApiClient.getErrorMessage(e);
    }
  }
}
