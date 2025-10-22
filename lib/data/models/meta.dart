class Meta {
  final Pagination pagination;

  Meta({required this.pagination});

  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(pagination: Pagination.fromJson(json));
}

class Pagination {
  final int total;
  final int pagesLeft;
  final int perPage;
  final int currentPage;
  final int totalPages;

  Pagination({
    required this.total,
    required this.pagesLeft,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'],
    pagesLeft: json['pages_left'],
    perPage: json['limit'],
    currentPage: json['page'],
    totalPages: json['total_pages'],
  );
}
