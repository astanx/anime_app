class Genre {
  final int id;
  final String name;
  final int? totalReleases;

  Genre({required this.id, required this.name, this.totalReleases});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(
      id: json['id'],
      name: json['name'],
      totalReleases: json['total_releases'] > 0 ? json['total_releases'] : null,
    );
  }

  static List<Genre> fromListJson(Map<String, dynamic> json) {
    return (json['results'] as List<dynamic>)
        .map((e) => Genre.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
