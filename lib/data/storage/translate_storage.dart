import 'package:shared_preferences/shared_preferences.dart';

class TranslateStorage {
  static const _key = 'translate_token';

  Future<void> saveLanguage(String language) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, language);
  }

  Future<String?> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_key);
  }

  Future<void> clearLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
