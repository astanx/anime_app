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

  History({
    required this.animeID,
    required this.lastWatchedEpisode,
    required this.isWatched,
  });

  History copyWith({
    String? animeID,
    int? lastWatchedEpisode,
    bool? isWatched,
  }) {
    return History(
      animeID: animeID ?? this.animeID,
      lastWatchedEpisode: lastWatchedEpisode ?? this.lastWatchedEpisode,
      isWatched: isWatched ?? this.isWatched,
    );
  }

  factory History.fromJson(Map<String, dynamic> json) => History(
    animeID: json['anime_id'],
    lastWatchedEpisode: json['last_watched'],
    isWatched: json['is_watched'] ?? false,
  );
}

class AnimeWithHistory {
  final History history;
  final Anime anime;

  AnimeWithHistory({required this.history, required this.anime});
}
