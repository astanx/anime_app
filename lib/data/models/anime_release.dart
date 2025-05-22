import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/models/shikimori_anime.dart';

class AnimeRelease {
  final int id;
  final AnimeType type;
  final int year;
  final AnimeNames names;
  final String alias;
  final AnimeSeason season;
  final Poster poster;
  final DateTime freshAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isOngoing;
  final AgeRating ageRating;
  final PublishDay publishDay;
  final String description;
  final int episodesTotal;
  final bool isInProduction;
  final bool isBlockedByGeo;
  final bool isBlockedByCopyrights;
  final int addedInUsersFavorites;
  final int averageDurationOfEpisode;
  final List<Genre> genres;
  final LatestEpisode latestEpisode;
  final String? shikimoriId;
  final KodikResult? kodikResult;

  AnimeRelease({
    required this.id,
    required this.type,
    required this.year,
    required this.names,
    required this.alias,
    required this.season,
    required this.poster,
    required this.freshAt,
    required this.createdAt,
    required this.updatedAt,
    required this.isOngoing,
    required this.ageRating,
    required this.publishDay,
    required this.description,
    required this.episodesTotal,
    required this.isInProduction,
    required this.isBlockedByGeo,
    required this.isBlockedByCopyrights,
    required this.addedInUsersFavorites,
    required this.averageDurationOfEpisode,
    required this.genres,
    required this.latestEpisode,
    this.shikimoriId,
    this.kodikResult,
  });

  factory AnimeRelease.fromJson(Map<String, dynamic> json) => AnimeRelease(
    id: json['id'] ?? 0,
    type: AnimeType.fromJson(json['type'] ?? {}),
    year: json['year'] ?? 0,
    names: AnimeNames.fromJson(json['name'] ?? {}),
    alias: json['alias'] ?? '',
    season: AnimeSeason.fromJson(json['season'] ?? {}),
    poster: Poster.fromJson(json['poster'] ?? {}),
    freshAt: DateTime.tryParse(json['fresh_at'] ?? '') ?? DateTime.now(),
    createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    isOngoing: json['is_ongoing'] ?? false,
    ageRating: AgeRating.fromJson(json['age_rating'] ?? {}),
    publishDay: PublishDay.fromJson(json['publish_day'] ?? {}),
    description: json['description'] ?? '',
    episodesTotal: json['episodes_total'] ?? 0,
    isInProduction: json['is_in_production'] ?? false,
    isBlockedByGeo: json['is_blocked_by_geo'] ?? false,
    isBlockedByCopyrights: json['is_blocked_by_copyrights'] ?? false,
    addedInUsersFavorites: json['added_in_users_favorites'] ?? 0,
    averageDurationOfEpisode: json['average_duration_of_episode'] ?? 0,
    genres:
        (json['genres'] as List? ?? []).map((e) => Genre.fromJson(e)).toList(),
    latestEpisode: LatestEpisode.fromJson(json['latest_episode'] ?? {}),
    shikimoriId: null,
    kodikResult: null,
  );

  factory AnimeRelease.fromKodik(KodikResult kodik) => AnimeRelease(
    id: -1,
    type: AnimeType(value: '', description: ''),
    year: kodik.year,
    names: AnimeNames(
      main: kodik.title,
      english: kodik.titleOrig,
      alternative: kodik.otherTitle,
    ),
    alias: '',
    season: AnimeSeason(value: null, description: null),
    poster: Poster(
      src: kodik.screenshots?.first ?? '',
      thumbnail: kodik.screenshots?.first ?? '',
      optimized: PosterOptimized(
        src: kodik.screenshots?.first ?? '',
        thumbnail: kodik.screenshots?.first ?? '',
      ),
    ),
    freshAt: DateTime.now(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    isOngoing: false,
    ageRating: AgeRating(value: '', label: '', isAdult: false, description: ''),
    publishDay: PublishDay(value: 0, description: ''),
    description: '',
    episodesTotal: kodik.type == 'anime-serial' ? 1 : 0,
    isInProduction: false,
    isBlockedByGeo: false,
    isBlockedByCopyrights: false,
    addedInUsersFavorites: 0,
    averageDurationOfEpisode: 0,
    genres: [],
    latestEpisode: LatestEpisode(
      id: '',
      name: null,
      ordinal: 0,
      preview: EpisodePreview(
        src: '',
        thumbnail: '',
        optimized: EpisodePreviewOptimized(src: '', thumbnail: ''),
      ),
      hls480: '',
      hls720: '',
      hls1080: '',
      duration: 0,
    ),
    shikimoriId: kodik.shikimoriId,
    kodikResult: kodik,
  );

  factory AnimeRelease.fromAnilibriaAndKodik(
    AnimeRelease original,
    KodikResult kodik,
  ) {
    return AnimeRelease(
      id: original.id,
      type: original.type,
      year: original.year,
      names: original.names,
      alias: original.alias,
      season: original.season,
      poster: original.poster,
      freshAt: original.freshAt,
      createdAt: original.createdAt,
      updatedAt: original.updatedAt,
      isOngoing: original.isOngoing,
      ageRating: original.ageRating,
      publishDay: original.publishDay,
      description: original.description,
      episodesTotal: original.episodesTotal,
      isInProduction: original.isInProduction,
      isBlockedByGeo: original.isBlockedByGeo,
      isBlockedByCopyrights: original.isBlockedByCopyrights,
      addedInUsersFavorites: original.addedInUsersFavorites,
      averageDurationOfEpisode: original.averageDurationOfEpisode,
      genres: original.genres,
      latestEpisode: original.latestEpisode,
      shikimoriId: kodik.shikimoriId,
      kodikResult: kodik,
    );
  }

  factory AnimeRelease.fromKodikAndShikimori(
    KodikResult kodik,
    ShikimoriAnime shikimori,
  ) {
    return AnimeRelease(
      id: -1,
      type: AnimeType(value: shikimori.kind, description: ''),
      year: kodik.year,
      names: AnimeNames(
        main: shikimori.name,
        english:
            shikimori.english.isNotEmpty
                ? shikimori.english.first
                : kodik.titleOrig,
        alternative:
            shikimori.synonyms.isNotEmpty
                ? shikimori.synonyms.first
                : kodik.otherTitle,
      ),
      alias: shikimori.franchise ?? '',
      season: _getSeasonFromDate(shikimori.airedOn),
      poster: Poster(
        src: shikimori.image.original,
        thumbnail: shikimori.image.preview,
        optimized: PosterOptimized(
          src: shikimori.image.original,
          thumbnail: shikimori.image.original,
        ),
      ),
      freshAt: shikimori.updatedAt,
      createdAt: DateTime.now(),
      updatedAt: shikimori.updatedAt,
      isOngoing: shikimori.ongoing,
      ageRating: _getAgeRating(shikimori.rating),
      publishDay: _getPublishDay(shikimori.airedOn),
      description: shikimori.description,
      episodesTotal: shikimori.episodes,
      isInProduction:
          shikimori.status == 'ongoing' || shikimori.status == 'anons',
      isBlockedByGeo: false,
      isBlockedByCopyrights: false,
      addedInUsersFavorites: 0,
      averageDurationOfEpisode: shikimori.duration,
      genres:
          shikimori.genres
              .map(
                (g) => Genre(
                  id: g.id,
                  name: g.name,
                  image: GenreImage(
                    preview: '',
                    thumbnail: '',
                    optimized: GenreImageOptimized(preview: '', thumbnail: ''),
                  ),
                ),
              )
              .toList(),
      latestEpisode: LatestEpisode(
        id: '',
        name: null,
        ordinal: 0,
        preview: EpisodePreview(
          src: '',
          thumbnail: '',
          optimized: EpisodePreviewOptimized(src: '', thumbnail: ''),
        ),
        hls480: '',
        hls720: '',
        hls1080: '',
        duration: 0,
      ),
      shikimoriId: kodik.shikimoriId,
      kodikResult: kodik,
    );
  }

  static AnimeSeason _getSeasonFromDate(DateTime? date) {
    if (date == null) return AnimeSeason(value: null, description: null);
    int month = date.month;
    String season;
    if (month >= 1 && month <= 3) {
      season = 'winter';
    } else if (month >= 4 && month <= 6) {
      season = 'spring';
    } else if (month >= 7 && month <= 9) {
      season = 'summer';
    } else {
      season = 'fall';
    }
    return AnimeSeason(value: season, description: season);
  }

  static AgeRating _getAgeRating(String? rating) {
    if (rating == null)
      return AgeRating(value: '', label: '', isAdult: false, description: '');
    String value = rating;
    String label = rating.toUpperCase();
    bool isAdult = rating.contains('r') || rating.contains('rx');
    return AgeRating(
      value: value,
      label: label,
      isAdult: isAdult,
      description: '',
    );
  }

  static PublishDay _getPublishDay(DateTime? date) {
    if (date == null) return PublishDay(value: 0, description: '');
    int day = date.weekday;
    int value = (day - 1) % 7;
    List<String> days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    String description = days[value];
    return PublishDay(value: value, description: description);
  }
}

class AnimeType {
  final String value;
  final String description;

  AnimeType({required this.value, required this.description});

  factory AnimeType.fromJson(Map<String, dynamic> json) => AnimeType(
    value: json['value'] ?? '',
    description: json['description'] ?? '',
  );
}

class AnimeNames {
  final String main;
  final String english;
  final String? alternative;

  AnimeNames({required this.main, required this.english, this.alternative});

  factory AnimeNames.fromJson(Map<String, dynamic> json) => AnimeNames(
    main: json['main'] ?? '',
    english: json['english'] ?? '',
    alternative: json['alternative'],
  );
}

class AnimeSeason {
  final String? value;
  final String? description;

  AnimeSeason({required this.value, required this.description});

  factory AnimeSeason.fromJson(Map<String, dynamic> json) => AnimeSeason(
    value: json['value'] ?? '',
    description: json['description'] ?? '',
  );
}

class Poster {
  final String src;
  final String thumbnail;
  final PosterOptimized optimized;

  Poster({required this.src, required this.thumbnail, required this.optimized});

  factory Poster.fromJson(Map<String, dynamic> json) => Poster(
    src: json['src'] ?? '',
    thumbnail: json['thumbnail'] ?? '',
    optimized: PosterOptimized.fromJson(json['optimized'] ?? {}),
  );
}

class PosterOptimized {
  final String src;
  final String thumbnail;

  PosterOptimized({required this.src, required this.thumbnail});

  factory PosterOptimized.fromJson(Map<String, dynamic> json) =>
      PosterOptimized(
        src: json['src'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
      );
}

class AgeRating {
  final String value;
  final String label;
  final bool isAdult;
  final String description;

  AgeRating({
    required this.value,
    required this.label,
    required this.isAdult,
    required this.description,
  });

  factory AgeRating.fromJson(Map<String, dynamic> json) => AgeRating(
    value: json['value'] ?? '',
    label: json['label'] ?? '',
    isAdult: json['is_adult'] ?? false,
    description: json['description'] ?? '',
  );
}

class PublishDay {
  final int value;
  final String description;

  PublishDay({required this.value, required this.description});

  factory PublishDay.fromJson(Map<String, dynamic> json) => PublishDay(
    value: json['value'] ?? 0,
    description: json['description'] ?? '',
  );
}

class Genre {
  final int id;
  final String name;
  final GenreImage image;

  Genre({required this.id, required this.name, required this.image});

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    image: GenreImage.fromJson(json['image'] ?? {}),
  );
}

class GenreImage {
  final String preview;
  final String thumbnail;
  final GenreImageOptimized optimized;

  GenreImage({
    required this.preview,
    required this.thumbnail,
    required this.optimized,
  });

  factory GenreImage.fromJson(Map<String, dynamic> json) => GenreImage(
    preview: json['preview'] ?? '',
    thumbnail: json['thumbnail'] ?? '',
    optimized: GenreImageOptimized.fromJson(json['optimized'] ?? {}),
  );
}

class GenreImageOptimized {
  final String preview;
  final String thumbnail;

  GenreImageOptimized({required this.preview, required this.thumbnail});

  factory GenreImageOptimized.fromJson(Map<String, dynamic> json) =>
      GenreImageOptimized(
        preview: json['preview'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
      );
}

class LatestEpisode {
  final String id;
  final String? name;
  final int ordinal;
  final EpisodePreview preview;
  final String hls480;
  final String hls720;
  final String hls1080;
  final int duration;
  final Opening? opening;
  final Ending? ending;
  final String? nameEnglish;

  LatestEpisode({
    required this.id,
    required this.name,
    required this.ordinal,
    required this.preview,
    required this.hls480,
    required this.hls720,
    required this.hls1080,
    required this.duration,
    this.opening,
    this.ending,
    this.nameEnglish,
  });

  factory LatestEpisode.fromJson(Map<String, dynamic> json) => LatestEpisode(
    id: json['id'] ?? '',
    name: json['name'],
    nameEnglish: json['name_english'],
    ordinal: json['ordinal'] ?? 0,
    preview: EpisodePreview.fromJson(json['preview'] ?? {}),
    hls480: json['hls_480'] ?? '',
    hls720: json['hls_720'] ?? '',
    hls1080: json['hls_1080'] ?? '',
    duration: json['duration'] ?? 0,
    opening: json['opening'] != null ? Opening.fromJson(json['opening']) : null,
    ending: json['ending'] != null ? Ending.fromJson(json['ending']) : null,
  );
}

class Opening {
  final int? start;
  final int? stop;

  Opening({required this.start, required this.stop});

  factory Opening.fromJson(Map<String, dynamic> json) =>
      Opening(start: json['start'], stop: json['stop']);
}

class Ending {
  final int? start;
  final int? stop;

  Ending({required this.start, required this.stop});

  factory Ending.fromJson(Map<String, dynamic> json) =>
      Ending(start: json['start'], stop: json['stop']);
}

class EpisodePreview {
  final String src;
  final String thumbnail;
  final EpisodePreviewOptimized optimized;

  EpisodePreview({
    required this.src,
    required this.thumbnail,
    required this.optimized,
  });

  factory EpisodePreview.fromJson(Map<String, dynamic> json) => EpisodePreview(
    src: json['src'] ?? '',
    thumbnail: json['thumbnail'] ?? '',
    optimized: EpisodePreviewOptimized.fromJson(json['optimized'] ?? {}),
  );
}

class EpisodePreviewOptimized {
  final String src;
  final String thumbnail;

  EpisodePreviewOptimized({required this.src, required this.thumbnail});

  factory EpisodePreviewOptimized.fromJson(Map<String, dynamic> json) =>
      EpisodePreviewOptimized(
        src: json['src'] ?? '',
        thumbnail: json['thumbnail'] ?? '',
      );
}
