import 'package:anime_app/data/models/anime.dart';

class History {
  final int animeId;
  final int lastWatchedEpisode;
  final bool isWatched;

  History({
    required this.animeId,
    required this.lastWatchedEpisode,
    required this.isWatched,
  });

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'lastWatchedEpisode': lastWatchedEpisode,
    'isWatched': isWatched,
  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    animeId: json['animeId'] as int,
    lastWatchedEpisode: json['lastWatchedEpisode'] as int,
    isWatched: json['isWatched'],
  );
}

class AnimeWithHistory {
  final Anime anime;
  final int lastWatchedEpisode;

  final bool isWatched;

  AnimeWithHistory({
    required this.anime,
    required this.lastWatchedEpisode,
    required this.isWatched,
  });

  static AnimeWithHistory combineWithHistory({
    required Anime anime,
    required History history,
  }) {
    return AnimeWithHistory(
      anime: anime,
      lastWatchedEpisode: history.lastWatchedEpisode,
      isWatched: history.isWatched,
    );
  }
}
