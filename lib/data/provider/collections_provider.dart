import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/data/repositories/user_repository.dart';

class CollectionsProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  final Map<CollectionType, Collection> _collections = {};
  final Map<CollectionType, bool> _hasFetched = {
    for (final type in CollectionType.values) type: false,
  };

  Map<CollectionType, Collection> get collections => _collections;

  Future<void> fetchCollection(CollectionType type, int page, int limit) async {
    if (!_hasFetched[type]!) {
      _collections[type] = await _repository.getCollections(type, page, limit);
      _hasFetched[type] = true;
      notifyListeners();
    }
  }

  Future<void> addToCollection(CollectionType type, Anime anime) async {
    if (anime.release.id != -1) {
      for (final entry in _collections.entries) {
        entry.value.data.removeWhere((a) => a.release.id == anime.release.id);
      }
      await _repository.addToCollection(type, anime.release.id);
    } else {
      for (final entry in _collections.entries) {
        entry.value.data.removeWhere(
          (a) =>
              a.release.kodikResult?.shikimoriId ==
              anime.release.kodikResult?.shikimoriId,
        );
      }
      await _repository.addToCollection(
        type,
        int.parse('$kodikIdPattern${anime.release.kodikResult?.shikimoriId}'),
      );
    }

    if (_collections[type] == null) {
      await fetchCollection(type, 1, 15);
    }
    _collections[type]!.data.add(anime);
    notifyListeners();
  }

  CollectionType? getCollectionType(Anime anime) {
    for (final entry in _collections.entries) {
      if (entry.value.data.any((a) => a.release.id == anime.release.id)) {
        return entry.key;
      }
    }
    return null;
  }
}
