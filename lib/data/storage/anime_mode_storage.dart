import 'package:anime_app/data/models/anime_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnimeModeStorage {
  static const _key = 'anime_mode_token';

  static Future<void> saveMode(AnimeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  static Future<AnimeMode> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return value == null ? AnimeMode.sub : AnimeModeExt.fromString(value);
  }

  static Future<void> clearMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
