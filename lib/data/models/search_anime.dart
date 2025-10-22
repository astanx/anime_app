class SearchAnime {
  final String id;
  final String title;
  final String poster;
  final int? year;
  final String type;
  final String parserType;

  SearchAnime({
    required this.id,
    required this.title,
    required this.poster,
    this.year,
    required this.type,
    required this.parserType,
  });

  factory SearchAnime.fromJson(Map<String, dynamic> json) => SearchAnime(
    id: json['id'],
    title: json['title'],
    poster: json['image'],
    year: json['year'] > 0 ? json['year'] : null,
    type: json['type'],
    parserType: json['parser_type'],
  );

  static List<SearchAnime> fromListJson(Map<String, dynamic> json) {
    return (json['results'] as List<dynamic>)
        .map((e) => SearchAnime.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
