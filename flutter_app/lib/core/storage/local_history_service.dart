import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/scan_result.dart';

class LocalHistoryService {
  static const String _keyHistory = 'local_scan_history_v1';

  static Future<List<ScanResult>> getHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? jsonStr = prefs.getString(_keyHistory);
      if (jsonStr == null || jsonStr.isEmpty) return [];

      final List<dynamic> list = jsonDecode(jsonStr);
      return list.map((item) => ScanResult.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveScan(ScanResult result) async {
    final history = await getHistory();
    // Prepend new scan to top
    history.insert(0, result);
    // Limit local history to 100 items
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await _persist(history);
  }

  static Future<void> deleteScan(String id) async {
    final history = await getHistory();
    history.removeWhere((item) => item.id == id);
    await _persist(history);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }

  static Future<void> _persist(List<ScanResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = history.map((item) => item.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }
}
