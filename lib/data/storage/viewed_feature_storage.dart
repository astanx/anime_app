import 'package:shared_preferences/shared_preferences.dart';

class ViewedFeatureStorage {
  static const _dubSubKey = 'saw_dub_sub_tutorial';

  static Future<void> setSawDubSubTutorial(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dubSubKey, value);
  }

  static Future<bool> getSawDubSubTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dubSubKey) ?? false;
  }

  static const _settingsKey = 'settings_tutorial';

  static Future<void> setSawSettingsTutorial(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_settingsKey, value);
  }

  static Future<bool> getSawSettingsTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_settingsKey) ?? false;
  }
}
