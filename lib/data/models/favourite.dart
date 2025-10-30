import 'package:anime_app/data/models/meta.dart';

class FavouriteMeta {
  List<String> animeIDs;
  final Meta meta;

  FavouriteMeta({required this.animeIDs, required this.meta});

  factory FavouriteMeta.fromJson(Map<String, dynamic> json) {
    return FavouriteMeta(
      animeIDs:
          (json['data'] as List<dynamic>)
              .map((e) => e['anime_id'].toString())
              .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }
}

class Favourite {
  final String animeID;

  Favourite({required this.animeID});

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(animeID: json['anime_id'].toString());
  }
}
