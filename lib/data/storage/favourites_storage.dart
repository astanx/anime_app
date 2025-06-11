import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class FavouritesStorage {
  static const _key = 'collection';

  static Future<void> updateFavorites(int id) async {
    final List<int> favoritesIds = await getFavoritesIds();
    final bool wasPresent = favoritesIds.contains(id);

    if (wasPresent) {
      favoritesIds.removeWhere((c) => c == id);
    } else {
      favoritesIds.add(id);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(favoritesIds));
  }

  static Future<List<int>> getFavoritesIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((e) => e as int).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> clearFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
