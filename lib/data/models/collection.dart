import 'package:anime_app/data/models/meta.dart';

class CollectionMeta {
  List<String> animeIDs;
  final CollectionType type;
  final Meta meta;

  CollectionMeta({
    required this.animeIDs,
    required this.meta,
    required this.type,
  });

  factory CollectionMeta.fromJson(Map<String, dynamic> json, String type) {
    return CollectionMeta(
      animeIDs:
          (json['data'] as List<dynamic>)
              .map((e) => e['anime_id'].toString())
              .toList(),
      type: CollectionType.fromString(type),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Collection {
  final String animeID;
  final CollectionType type;

  Collection({required this.animeID, required this.type});

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      animeID: json['anime_id'].toString(),
      type: CollectionType.fromString(json['type']),
    );
  }
}

enum CollectionType {
  planned,
  watched,
  watching,
  abandoned;

  String get asQueryParam {
    switch (this) {
      case CollectionType.planned:
        return 'PLANNED';
      case CollectionType.watched:
        return 'WATCHED';
      case CollectionType.watching:
        return 'WATCHING';
      case CollectionType.abandoned:
        return 'ABANDONED';
    }
  }

  static CollectionType fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PLANNED':
        return CollectionType.planned;
      case 'WATCHED':
        return CollectionType.watched;
      case 'WATCHING':
        return CollectionType.watching;
      case 'ABANDONED':
        return CollectionType.abandoned;
      default:
        throw ArgumentError('Invalid CollectionType: $value');
    }
  }
}
