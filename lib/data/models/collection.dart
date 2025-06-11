import 'package:anime_app/data/models/anime.dart';

class Collection {
  List<Anime> data;
  final Meta meta;

  Collection({required this.data, required this.meta});

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      data:
          (json['data'] as List<dynamic>)
              .map((e) => Anime.fromJson(e))
              .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Meta {
  final Pagination pagination;

  Meta({required this.pagination});

  factory Meta.fromJson(Map<String, dynamic> json) =>
      Meta(pagination: Pagination.fromJson(json['pagination']));
}

class Pagination {
  final int total;
  final int count;
  final int perPage;
  final int currentPage;
  final int totalPages;
  final Map<String, dynamic> links;

  Pagination({
    required this.total,
    required this.count,
    required this.perPage,
    required this.currentPage,
    required this.totalPages,
    required this.links,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    total: json['total'] as int,
    count: json['count'] as int,
    perPage: json['per_page'] as int,
    currentPage: json['current_page'] as int,
    totalPages: json['total_pages'] as int,
    links: json['links'] as Map<String, dynamic>? ?? {},
  );
}

class CollectionId {
  final int id;
  final String status;

  CollectionId({required this.id, required this.status});

  factory CollectionId.fromList(List<dynamic> list) {
    return CollectionId(id: list[0] as int, status: list[1] as String);
  }

  factory CollectionId.fromJson(Map<String, dynamic> json) {
    return CollectionId(
      id: json['id'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'status': status};
  }
}

enum CollectionType {
  planned,
  watched,
  watching,
  postponed,
  abandoned;

  String get asQueryParam {
    switch (this) {
      case CollectionType.planned:
        return 'PLANNED';
      case CollectionType.watched:
        return 'WATCHED';
      case CollectionType.watching:
        return 'WATCHING';

      case CollectionType.postponed:
        return 'POSTPONED';
      case CollectionType.abandoned:
        return 'ABANDONED';
    }
  }
}
