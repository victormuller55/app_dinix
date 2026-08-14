import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Cache local das listagens da UI.
///
/// - TTL: 5 minutos.
/// - Recarrega da API com [forceRefresh] no pull-to-refresh, ou após
///   cadastro/edição/exclusão (invalidate + reload).
class PageDataCache {
  PageDataCache._();

  static const Duration ttl = Duration(minutes: 5);
  static const _prefix = 'page_cache_';
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

  static Future<Map<String, dynamic>?> getJsonMap(
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
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      if (decoded is List) {
        return {
          'itens': decoded,
          'itens_pag': decoded.length,
          'max_itens': decoded.length,
          'num_pag': 1,
          'max_pag': decoded.isEmpty ? 0 : 1,
        };
      }
      await invalidate(key);
      return null;
    } catch (_) {
      await invalidate(key);
      return null;
    }
  }

  static Future<void> setJsonMap(String key, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_prefix$key', jsonEncode(data));
    await prefs.setInt('$_prefix$key$_tsSuffix', DateTime.now().millisecondsSinceEpoch);
  }

  static Future<void> invalidate(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefix$key');
    await prefs.remove('$_prefix$key$_tsSuffix');
  }

  static Future<void> invalidatePrefix(String prefix) async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((key) => key.startsWith('$_prefix$prefix'));
    for (final key in keys) {
      await prefs.remove(key);
    }
  }

  static Future<bool> isFresh(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt('$_prefix$key$_tsSuffix');
    final raw = prefs.getString('$_prefix$key');
    if (raw == null || raw.isEmpty || timestamp == null) return false;
    return !_isExpired(timestamp);
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
