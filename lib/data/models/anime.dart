class Anime {
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

  Anime({
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
  });

  factory Anime.fromJson(Map<String, dynamic> json) => Anime(
    id: json['id'] ?? 0,
    type:
        json['type'] != null
            ? AnimeType.fromJson(json['type'])
            : AnimeType(value: '', description: ''),
    year: json['year'] ?? 0,
    names: AnimeNames.fromJson(json['name'] ?? {}),
    alias: json['alias'] ?? '',
    season:
        json['season'] != null
            ? AnimeSeason.fromJson(json['season'])
            : AnimeSeason(value: '', description: ''),
    poster:
        json['poster'] != null
            ? Poster.fromJson(json['poster'])
            : Poster(
              src: '',
              thumbnail: '',
              optimized: PosterOptimized(src: '', thumbnail: ''),
            ),
    freshAt:
        json['fresh_at'] != null
            ? DateTime.parse(json['fresh_at'])
            : DateTime.now(),
    createdAt:
        json['created_at'] != null
            ? DateTime.parse(json['created_at'])
            : DateTime.now(),
    updatedAt:
        json['updated_at'] != null
            ? DateTime.parse(json['updated_at'])
            : DateTime.now(),
    isOngoing: json['is_ongoing'] ?? false,
    ageRating:
        json['age_rating'] != null
            ? AgeRating.fromJson(json['age_rating'])
            : AgeRating(value: '', label: '', isAdult: false, description: ''),
    publishDay:
        json['publish_day'] != null
            ? PublishDay.fromJson(json['publish_day'])
            : PublishDay(value: 0, description: ''),
    description: json['description'] ?? '',
    episodesTotal: json['episodes_total'] ?? 0,
    isInProduction: json['is_in_production'] ?? false,
    isBlockedByGeo: json['is_blocked_by_geo'] ?? false,
    isBlockedByCopyrights: json['is_blocked_by_copyrights'] ?? false,
    addedInUsersFavorites: json['added_in_users_favorites'] ?? 0,
    averageDurationOfEpisode: json['average_duration_of_episode'] ?? 0,
    genres:
        (json['genres'] as List<dynamic>? ?? [])
            .map((e) => Genre.fromJson(e))
            .toList(),
    latestEpisode:
        json['latest_episode'] != null
            ? LatestEpisode.fromJson(json['latest_episode'])
            : LatestEpisode(
              id: '',
              name: '',
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
  );
}

class AnimeType {
  final String value;
  final String description;

  AnimeType({required this.value, required this.description});

  factory AnimeType.fromJson(Map<String, dynamic> json) =>
      AnimeType(value: json['value'], description: json['description']);
}

class AnimeNames {
  final String main;
  final String english;
  final String? alternative;

  AnimeNames({required this.main, required this.english, this.alternative});

  factory AnimeNames.fromJson(Map<String, dynamic> json) => AnimeNames(
    main: json['main'],
    english: json['english'],
    alternative: json['alternative'],
  );
}

class AnimeSeason {
  final String value;
  final String description;

  AnimeSeason({required this.value, required this.description});

  factory AnimeSeason.fromJson(Map<String, dynamic> json) =>
      AnimeSeason(value: json['value'], description: json['description']);
}

class Poster {
  final String src;
  final String thumbnail;
  final PosterOptimized optimized;

  Poster({required this.src, required this.thumbnail, required this.optimized});

  factory Poster.fromJson(Map<String, dynamic> json) => Poster(
    src: json['src'],
    thumbnail: json['thumbnail'],
    optimized: PosterOptimized.fromJson(json['optimized']),
  );
}

class PosterOptimized {
  final String src;
  final String thumbnail;

  PosterOptimized({required this.src, required this.thumbnail});

  factory PosterOptimized.fromJson(Map<String, dynamic> json) =>
      PosterOptimized(src: json['src'], thumbnail: json['thumbnail']);
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
    value: json['value'],
    label: json['label'],
    isAdult: json['is_adult'],
    description: json['description'],
  );
}

class PublishDay {
  final int value;
  final String description;

  PublishDay({required this.value, required this.description});

  factory PublishDay.fromJson(Map<String, dynamic> json) =>
      PublishDay(value: json['value'], description: json['description']);
}

class Genre {
  final int id;
  final String name;
  final GenreImage image;

  Genre({required this.id, required this.name, required this.image});

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
    id: json['id'],
    name: json['name'],
    image: GenreImage.fromJson(json['image']),
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
    preview: json['preview'],
    thumbnail: json['thumbnail'],
    optimized: GenreImageOptimized.fromJson(json['optimized']),
  );
}

class GenreImageOptimized {
  final String preview;
  final String thumbnail;

  GenreImageOptimized({required this.preview, required this.thumbnail});

  factory GenreImageOptimized.fromJson(Map<String, dynamic> json) =>
      GenreImageOptimized(
        preview: json['preview'],
        thumbnail: json['thumbnail'],
      );
}

class LatestEpisode {
  final String id;
  final String name;
  final int ordinal;
  final EpisodePreview preview;
  final String hls480;
  final String hls720;
  final String hls1080;
  final int duration;

  LatestEpisode({
    required this.id,
    required this.name,
    required this.ordinal,
    required this.preview,
    required this.hls480,
    required this.hls720,
    required this.hls1080,
    required this.duration,
  });

  factory LatestEpisode.fromJson(Map<String, dynamic> json) => LatestEpisode(
    id: json['id'] ?? 0,
    name: json['name'] ?? '',
    ordinal: json['ordinal'] ?? 0,
    preview:
        json['preview'] != null
            ? EpisodePreview.fromJson(json['preview'])
            : EpisodePreview(
              src: '',
              thumbnail: '',
              optimized: EpisodePreviewOptimized(src: '', thumbnail: ''),
            ),
    hls480: json['hlt_480'] ?? '',
    hls720: json['hls_720'] ?? '',
    hls1080: json['hls_1080'] ?? '',
    duration: json['duration'] ?? 0,
  );
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
    src: json['src'],
    thumbnail: json['thumbnail'],
    optimized: EpisodePreviewOptimized.fromJson(json['optimized']),
  );
}

class EpisodePreviewOptimized {
  final String src;
  final String thumbnail;

  EpisodePreviewOptimized({required this.src, required this.thumbnail});

  factory EpisodePreviewOptimized.fromJson(Map<String, dynamic> json) =>
      EpisodePreviewOptimized(src: json['src'], thumbnail: json['thumbnail']);
}
