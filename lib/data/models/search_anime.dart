class PaginatedSearchAnime {
  List<SearchAnime> results;
  int currentPage;
  int totalPages;
  bool hasNextPage;

  PaginatedSearchAnime({
    required this.results,
    required this.currentPage,
    required this.totalPages,
    required this.hasNextPage,
  });

  factory PaginatedSearchAnime.fromJson(Map<String, dynamic> json) {
    json = json["results"];
    return PaginatedSearchAnime(
      results: SearchAnime.fromListJsonPaginated(json),
      currentPage: json['meta']['current_page'],
      totalPages: json['meta']['total_pages'],
      hasNextPage: json['meta']['has_next_page'],
    );
  }

  PaginatedSearchAnime copyWith({
    List<SearchAnime>? results,
    int? currentPage,
    int? totalPages,
    bool? hasNextPage,
  }) {
    return PaginatedSearchAnime(
      results: results ?? this.results,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
    );
  }
}

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

  static List<SearchAnime> fromListJsonPaginated(Map<String, dynamic> json) {
    return (json['data'] as List<dynamic>)
        .map((e) => SearchAnime.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
