class ShikimoriAnime {
  final int id;
  final String name;
  final String russian;
  final AnimeImage image;
  final String url;
  final String kind;
  final String score;
  final String status;
  final int episodes;
  final int episodesAired;
  final DateTime? airedOn;
  final DateTime? releasedOn;
  final String rating;
  final List<String> english;
  final List<String> japanese;
  final List<String> synonyms;
  final String? licenseNameRu;
  final int duration;
  final String? description;
  final String descriptionHtml;
  final String? franchise;
  final bool favoured;
  final bool anons;
  final bool ongoing;
  final int threadId;
  final int topicId;
  final int myanimelistId;
  final List<RateScoreStat> ratesScoresStats;
  final List<RateStatusStat> ratesStatusesStats;
  final DateTime updatedAt;
  final DateTime? nextEpisodeAt;
  final List<String> fansubbers;
  final List<String> fandubbers;
  final List<String> licensors;
  final List<ShikimoriGenre> genres;
  final List<Studio> studios;
  final List<Video> videos;
  final List<Screenshot> screenshots;
  final dynamic userRate;

  ShikimoriAnime({
    required this.id,
    required this.name,
    required this.russian,
    required this.image,
    required this.url,
    required this.kind,
    required this.score,
    required this.status,
    required this.episodes,
    required this.episodesAired,
    required this.airedOn,
    required this.releasedOn,
    required this.rating,
    required this.english,
    required this.japanese,
    required this.synonyms,
    required this.licenseNameRu,
    required this.duration,
    required this.description,
    required this.descriptionHtml,
    required this.franchise,
    required this.favoured,
    required this.anons,
    required this.ongoing,
    required this.threadId,
    required this.topicId,
    required this.myanimelistId,
    required this.ratesScoresStats,
    required this.ratesStatusesStats,
    required this.updatedAt,
    required this.nextEpisodeAt,
    required this.fansubbers,
    required this.fandubbers,
    required this.licensors,
    required this.genres,
    required this.studios,
    required this.videos,
    required this.screenshots,
    required this.userRate,
  });

  factory ShikimoriAnime.fromJson(Map<String, dynamic> json) {
    return ShikimoriAnime(
      id: json['id'],
      name: json['name'],
      russian: json['russian'],
      image: AnimeImage.fromJson(json['image']),
      url: json['url'],
      kind: json['kind'],
      score: json['score'],
      status: json['status'],
      episodes: json['episodes'],
      episodesAired: json['episodes_aired'],
      airedOn:
          json['aired_on'] != null ? DateTime.tryParse(json['aired_on']) : null,
      releasedOn:
          json['released_on'] != null
              ? DateTime.tryParse(json['released_on'])
              : null,
      rating: json['rating'],
      english:
          (json['english'] as List<dynamic>?)?.whereType<String>().toList() ??
          [],
      japanese:
          (json['japanese'] as List<dynamic>?)?.whereType<String>().toList() ??
          [],
      synonyms:
          (json['synonyms'] as List<dynamic>?)?.whereType<String>().toList() ??
          [],
      fansubbers:
          (json['fansubbers'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      fandubbers:
          (json['fandubbers'] as List<dynamic>?)
              ?.whereType<String>()
              .toList() ??
          [],
      licensors:
          (json['licensors'] as List<dynamic>?)?.whereType<String>().toList() ??
          [],
      licenseNameRu: json['license_name_ru'],
      duration: json['duration'],
      description: json['description'],
      descriptionHtml: json['description_html'],
      franchise: json['franchise'],
      favoured: json['favoured'],
      anons: json['anons'],
      ongoing: json['ongoing'],
      threadId: json['thread_id'],
      topicId: json['topic_id'],
      myanimelistId: json['myanimelist_id'],
      ratesScoresStats:
          (json['rates_scores_stats'] as List)
              .map((e) => RateScoreStat.fromJson(e))
              .toList(),
      ratesStatusesStats:
          (json['rates_statuses_stats'] as List)
              .map((e) => RateStatusStat.fromJson(e))
              .toList(),
      updatedAt: DateTime.parse(json['updated_at']),
      nextEpisodeAt:
          json['next_episode_at'] != null
              ? DateTime.tryParse(json['next_episode_at'])
              : null,
      genres:
          (json['genres'] as List)
              .map((e) => ShikimoriGenre.fromJson(e))
              .toList(),
      studios:
          (json['studios'] as List).map((e) => Studio.fromJson(e)).toList(),
      videos: (json['videos'] as List).map((e) => Video.fromJson(e)).toList(),
      screenshots:
          (json['screenshots'] as List)
              .map((e) => Screenshot.fromJson(e))
              .toList(),
      userRate: json['user_rate'],
    );
  }
}

class AnimeImage {
  final String original;
  final String preview;
  final String x96;
  final String x48;

  AnimeImage({
    required this.original,
    required this.preview,
    required this.x96,
    required this.x48,
  });

  factory AnimeImage.fromJson(Map<String, dynamic> json) {
    return AnimeImage(
      original: json['original'],
      preview: json['preview'],
      x96: json['x96'],
      x48: json['x48'],
    );
  }
}

class RateScoreStat {
  final int name;
  final int value;

  RateScoreStat({required this.name, required this.value});

  factory RateScoreStat.fromJson(Map<String, dynamic> json) {
    return RateScoreStat(name: json['name'], value: json['value']);
  }
}

class RateStatusStat {
  final String name;
  final int value;

  RateStatusStat({required this.name, required this.value});

  factory RateStatusStat.fromJson(Map<String, dynamic> json) {
    return RateStatusStat(name: json['name'], value: json['value']);
  }
}

class ShikimoriGenre {
  final int id;
  final String name;
  final String russian;
  final String kind;
  final String entryType;

  ShikimoriGenre({
    required this.id,
    required this.name,
    required this.russian,
    required this.kind,
    required this.entryType,
  });

  factory ShikimoriGenre.fromJson(Map<String, dynamic> json) {
    return ShikimoriGenre(
      id: json['id'],
      name: json['name'],
      russian: json['russian'],
      kind: json['kind'],
      entryType: json['entry_type'],
    );
  }
}

class Studio {
  final int id;
  final String name;
  final String filteredName;
  final bool real;
  final String? image;

  Studio({
    required this.id,
    required this.name,
    required this.filteredName,
    required this.real,
    required this.image,
  });

  factory Studio.fromJson(Map<String, dynamic> json) {
    return Studio(
      id: json['id'],
      name: json['name'],
      filteredName: json['filtered_name'],
      real: json['real'],
      image: json['image'],
    );
  }
}

class Video {
  final int id;
  final String url;
  final String imageUrl;
  final String playerUrl;
  final String? name;
  final String kind;
  final String hosting;

  Video({
    required this.id,
    required this.url,
    required this.imageUrl,
    required this.playerUrl,
    required this.name,
    required this.kind,
    required this.hosting,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: json['id'],
      url: json['url'],
      imageUrl: json['image_url'],
      playerUrl: json['player_url'],
      name: json['name'],
      kind: json['kind'],
      hosting: json['hosting'],
    );
  }
}

class Screenshot {
  final String original;
  final String preview;

  Screenshot({required this.original, required this.preview});

  factory Screenshot.fromJson(Map<String, dynamic> json) {
    return Screenshot(original: json['original'], preview: json['preview']);
  }
}
