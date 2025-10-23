import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/meta.dart';

class HistoryData {
  final List<History> history;
  final Meta meta;

  HistoryData({required this.history, required this.meta});

  factory HistoryData.fromJson(Map<String, dynamic> json) {
    return HistoryData(
      history:
          (json['data'] as List<dynamic>)
              .map((e) => History.fromJson(e))
              .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class History {
  final String animeID;
  final int lastWatchedEpisode;
  final bool isWatched;
  final DateTime? watchedAt;

  History({
    required this.animeID,
    required this.lastWatchedEpisode,
    required this.isWatched,
    required this.watchedAt,
  });

  factory History.fromJson(Map<String, dynamic> json) => History(
    animeID: json['anime_id'],
    lastWatchedEpisode: json['last_watched'],
    isWatched: json['is_watched'] ?? false,
    watchedAt: DateTime.parse(json['watched_at']),
  );
}

class AnimeWithHistory {
  final History history;
  final Anime anime;

  AnimeWithHistory({required this.history, required this.anime});
}
