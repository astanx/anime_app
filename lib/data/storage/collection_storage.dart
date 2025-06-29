import 'dart:convert';
import 'package:anime_app/data/models/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollectionStorage {
  static const _key = 'collection';

  static Future<void> updateCollection(int id, CollectionType type) async {
    final List<CollectionId> collectionIds = await getCollectionIds();

    collectionIds.removeWhere((c) {
      return c.id == id;
    });

    collectionIds.add(
      CollectionId(id: id, status: type.asQueryParam.toUpperCase()),
    );

    final prefs = await SharedPreferences.getInstance();
    final jsonList = collectionIds.map((c) => c.toJson()).toList();
    await prefs.setString(_key, jsonEncode(jsonList));
  }

  static Future<List<CollectionId>> getCollectionIds() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);

    if (jsonString == null) return [];

    final List<dynamic> jsonList = jsonDecode(jsonString);
    return jsonList
        .map((e) => CollectionId.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> clearCollections() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
