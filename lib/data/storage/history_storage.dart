import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:anime_app/data/models/history.dart';

class HistoryStorage {
  static const _key = 'history';

  static Future<void> updateHistory(History history) async {
    final List<History> histories = await getHistory();

    histories.removeWhere((h) {
      if (history.animeId != -1 && h.animeId != -1) {
        return h.animeId == history.animeId;
      }

      final kodikId1 = history.kodikResult?.id;
      final kodikId2 = h.kodikResult?.id;
      return kodikId1 != null && kodikId2 != null && kodikId1 == kodikId2;
    });

    histories.add(history);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = histories.map((h) => h.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<History>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((e) => History.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  static Future<int> getEpisodeIndex(int animeId) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return 0;

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((e) => History.fromJson(e as Map<String, dynamic>))
        .firstWhere(
          (h) => h.uniqueId == animeId,
          orElse:
              () => History(
                isWatched: false,
                lastWatchedEpisode: 0,
                animeId: animeId,
              ),
        )
        .lastWatchedEpisode;
  }
}
