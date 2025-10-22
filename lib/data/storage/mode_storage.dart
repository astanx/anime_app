import 'package:anime_app/data/models/mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ModeStorage {
  static const _key = 'mode_token';

  static Future<void> saveMode(Mode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, mode.name);
  }

  static Future<Mode> getMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_key);
    return value == null ? Mode.consumet : ModeExt.fromString(value);
  }

  static Future<void> clearMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
