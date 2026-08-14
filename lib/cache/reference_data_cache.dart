import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache persistente de lookups (categorias, contas, etc.).
class ReferenceDataCache {
  ReferenceDataCache._();

  static const Duration ttl = Duration(days: 7);
  static const _prefix = 'ref_cache_';
  static const _tsSuffix = '_ts';

  static Future<List<Map<String, dynamic>>?> getJsonList(
    String key, {
    bool allowStale = false,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$_prefix$key$_tsSuffix');
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty) return null;

    if (timestamp != null && _isExpired(timestamp) && !allowStale) {
      return null;
    }

    try {
      final decoded = jsonDecode(raw) as List;
      return decoded.map((item) => Map<String, dynamic>.from(item as Map)).toList();
    } catch (_) {
      await invalidate(key);
      return null;
    }
  }

  static Future<void> setJsonList(String key, List<Map<String, dynamic>> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode(data));
    await prefs.setInt('$_prefix$key$_tsSuffix', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
    await prefs.remove('$_prefix$key$_tsSuffix');
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith(_prefix));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static bool _isExpired(int timestampMs) {
    final age = DateTime.now().millisecondsSinceEpoch - timestampMs;
    return age > ttl.inMilliseconds;
  }
}
