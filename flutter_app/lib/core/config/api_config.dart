import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  static const String defaultProductionUrl = 'https://upi-scam-analyzer.onrender.com';
  static const String defaultEmulatorUrl = 'http://10.0.2.2:5000';
  static const String defaultLocalUrl = 'http://192.168.1.10:5000';

  static const String keyBaseUrl = 'custom_base_url';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  static String _currentBaseUrl = defaultProductionUrl;

  static String get baseUrl => _currentBaseUrl;

  static bool get isProduction => _currentBaseUrl == defaultProductionUrl;

  static String get environmentName {
    if (_currentBaseUrl == defaultProductionUrl) {
      return 'Production Cloud';
    } else if (_currentBaseUrl == defaultEmulatorUrl) {
      return 'Android Emulator';
    } else if (_currentBaseUrl == defaultLocalUrl) {
      return 'Local Wi-Fi Network';
    }
    return 'Custom Endpoint';
  }

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _currentBaseUrl = prefs.getString(keyBaseUrl) ?? defaultProductionUrl;
    if (_currentBaseUrl.endsWith('/')) {
      _currentBaseUrl = _currentBaseUrl.substring(0, _currentBaseUrl.length - 1);
    }
  }

  static Future<void> setBaseUrl(String url) async {
    var formattedUrl = url.trim();
    if (formattedUrl.endsWith('/')) {
      formattedUrl = formattedUrl.substring(0, formattedUrl.length - 1);
    }
    _currentBaseUrl = formattedUrl;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyBaseUrl, formattedUrl);
  }
}
