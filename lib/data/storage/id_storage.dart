import 'package:shared_preferences/shared_preferences.dart';

class IDStorage {
  static const _key = 'id_token';

  static Future<void> saveID(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, id);
  }

  static Future<String?> getID() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  static Future<void> clearID() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
