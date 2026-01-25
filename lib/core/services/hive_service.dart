import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static SharedPreferences get prefs {
    if (_prefs == null) {
      throw Exception('StorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // String operations
  static String? getString(String key) => prefs.getString(key);
  static Future<bool> setString(String key, String value) => prefs.setString(key, value);

  // Int operations
  static int? getInt(String key) => prefs.getInt(key);
  static Future<bool> setInt(String key, int value) => prefs.setInt(key, value);

  // Bool operations
  static bool? getBool(String key) => prefs.getBool(key);
  static Future<bool> setBool(String key, bool value) => prefs.setBool(key, value);

  // StringList operations
  static List<String>? getStringList(String key) => prefs.getStringList(key);
  static Future<bool> setStringList(String key, List<String> value) => prefs.setStringList(key, value);

  // Remove and clear
  static Future<bool> remove(String key) => prefs.remove(key);
  static Future<bool> clear() => prefs.clear();

  // Check if key exists
  static bool containsKey(String key) => prefs.containsKey(key);
}
