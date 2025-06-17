import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/kodik_result.dart';

class History {
  final int animeId;
  final int lastWatchedEpisode;
  final bool isWatched;
  final KodikResult? kodikResult;

  int get uniqueId {
    if (animeId != -1) return animeId;
    if (kodikResult != null) {
      return int.parse('$kodikIdPattern${kodikResult!.shikimoriId}');
    }
    return -1;
  }

  History({
    required this.animeId,
    required this.lastWatchedEpisode,
    required this.isWatched,
    this.kodikResult,
  });

  Map<String, dynamic> toJson() => {
    'animeId': animeId,
    'lastWatchedEpisode': lastWatchedEpisode,
    'isWatched': isWatched,
    'kodikResult': kodikResult?.toJson(),
  };

  factory History.fromJson(Map<String, dynamic> json) => History(
    animeId: json['animeId'] as int,
    lastWatchedEpisode: json['lastWatchedEpisode'] as int,
    isWatched: json['isWatched'] ?? false,
    kodikResult:
        json['kodikResult'] != null
            ? KodikResult.fromJson(json['kodikResult'])
            : null,
  );
}

class AnimeWithHistory {
  final Anime anime;
  final int lastWatchedEpisode;
  final bool isWatched;
  final KodikResult? kodikResult;

  AnimeWithHistory({
    required this.anime,
    required this.lastWatchedEpisode,
    required this.isWatched,
    this.kodikResult,
  });

  static AnimeWithHistory combineWithHistory({
    required Anime anime,
    required History history,
  }) {
    return AnimeWithHistory(
      anime: anime,
      lastWatchedEpisode: history.lastWatchedEpisode,
      isWatched: history.isWatched,
      kodikResult: history.kodikResult,
    );
  }
}
