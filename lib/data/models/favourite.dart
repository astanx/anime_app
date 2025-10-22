import 'package:anime_app/data/models/meta.dart';

class Favourite {
  List<String> animeIDs;
  final Meta meta;

  Favourite({required this.animeIDs, required this.meta});

  factory Favourite.fromJson(Map<String, dynamic> json) {
    return Favourite(
      animeIDs:
          (json['data'] as List<dynamic>)
              .map((e) => e['anime_id'].toString())
              .toList(),
      meta: Meta.fromJson(json['meta']),
    );
  }
}
