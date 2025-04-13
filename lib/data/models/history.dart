import 'package:anime_app/data/models/anime.dart';

class History {
  final int animeId;
  final int lastWatchedEpisode;

  History({required this.animeId, required this.lastWatchedEpisode});

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'lastWatchedEpisode': lastWatchedEpisode,
  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    animeId: json['animeId'] as int,
    lastWatchedEpisode: json['lastWatchedEpisode'] as int,
  );
}

class AnimeWithHistory {
  final Anime anime;
  final int lastWatchedEpisode;

  AnimeWithHistory({required this.anime, required this.lastWatchedEpisode});

  static AnimeWithHistory combineWithHistory({
    required Anime anime,
    required History history,
  }) {
    return AnimeWithHistory(
      anime: anime,
      lastWatchedEpisode: history.lastWatchedEpisode,
    );
  }
}
