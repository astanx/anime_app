import 'package:anime_app/data/models/anime_release.dart';

class Franchise {
  final String id;
  final String name;
  final ImageFranchise image;
  final double? rating;
  final int lastYear;
  final int firstYear;
  final String nameEnglish;
  final int totalEpisodes;
  final int totalReleases;
  final String totalDuration;
  final int totalDurationInSeconds;
  final List<FranchiseRelease> franchiseReleases;

  Franchise({
    required this.id,
    required this.name,
    required this.image,
    this.rating,
    required this.lastYear,
    required this.firstYear,
    required this.nameEnglish,
    required this.totalEpisodes,
    required this.totalReleases,
    required this.totalDuration,
    required this.totalDurationInSeconds,
    required this.franchiseReleases,
  });

  factory Franchise.fromJson(Map<String, dynamic> json) => Franchise(
    id: json['id'] as String? ?? '',
    name: json['name'] as String? ?? '',
    image: ImageFranchise.fromJson(json['image'] ?? {}),
    rating: json['rating'] as double?,
    lastYear: json['last_year'] as int? ?? 0,
    firstYear: json['first_year'] as int? ?? 0,
    nameEnglish: json['name_english'] as String? ?? '',
    totalEpisodes: json['total_episodes'] as int? ?? 0,
    totalReleases: json['total_releases'] as int? ?? 0,
    totalDuration: json['total_duration'] as String? ?? '',
    totalDurationInSeconds: json['total_duration_in_seconds'] as int? ?? 0,
    franchiseReleases:
        (json['franchise_releases'] as List<dynamic>?)
            ?.map((e) => FranchiseRelease.fromJson(e))
            .toList() ??
        [],
  );
}

class FranchiseRelease {
  final String id;
  final int sortOrder;
  final int releaseId;
  final String franchiseId;
  final AnimeRelease release;

  FranchiseRelease({
    required this.id,
    required this.sortOrder,
    required this.releaseId,
    required this.franchiseId,
    required this.release,
  });

  factory FranchiseRelease.fromJson(Map<String, dynamic> json) =>
      FranchiseRelease(
        id: json['id'] as String? ?? '',
        sortOrder: json['sort_order'] as int? ?? 0,
        releaseId: json['release_id'] as int? ?? 0,
        franchiseId: json['franchise_id'] as String? ?? '',
        release: AnimeRelease.fromJson(json['release'] ?? {}),
      );
}

class ImageFranchise {
  final String preview;
  final String thumbnail;
  final ImageFranchiseOptimized optimized;

  ImageFranchise({
    required this.preview,
    required this.thumbnail,
    required this.optimized,
  });

  factory ImageFranchise.fromJson(Map<String, dynamic> json) => ImageFranchise(
    preview: json['preview'] as String? ?? '',
    thumbnail: json['thumbnail'] as String? ?? '',
    optimized: ImageFranchiseOptimized.fromJson(json['optimized'] ?? {}),
  );
}

class ImageFranchiseOptimized {
  final String preview;
  final String thumbnail;

  ImageFranchiseOptimized({required this.preview, required this.thumbnail});

  factory ImageFranchiseOptimized.fromJson(Map<String, dynamic> json) =>
      ImageFranchiseOptimized(
        preview: json['preview'] as String? ?? '',
        thumbnail: json['thumbnail'] as String? ?? '',
      );
}
