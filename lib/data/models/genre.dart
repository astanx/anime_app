class Genre {
  final int id;
  final String name;
  final GenreImage image;
  final int totalReleases;

  Genre({
    required this.id,
    required this.name,
    required this.image,
    required this.totalReleases,
  });

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      image: GenreImage.fromJson(json['image']),
      totalReleases: json['total_releases'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image.toJson(),
      'total_releases': totalReleases,
    };
  }
}

class GenreImage {
  final String preview;
  final String thumbnail;
  final GenreOptimizedImage optimized;

  GenreImage({
    required this.preview,
    required this.thumbnail,
    required this.optimized,
  });

  factory GenreImage.fromJson(Map<String, dynamic> json) {
    return GenreImage(
      preview: json['preview'],
      thumbnail: json['thumbnail'],
      optimized: GenreOptimizedImage.fromJson(json['optimized']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'preview': preview,
      'thumbnail': thumbnail,
      'optimized': optimized.toJson(),
    };
  }
}

class GenreOptimizedImage {
  final String preview;
  final String thumbnail;

  GenreOptimizedImage({required this.preview, required this.thumbnail});

  factory GenreOptimizedImage.fromJson(Map<String, dynamic> json) {
    return GenreOptimizedImage(
      preview: json['preview'],
      thumbnail: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'preview': preview, 'thumbnail': thumbnail};
  }
}
