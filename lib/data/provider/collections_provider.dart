import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/repositories/collection_repository.dart';
import 'package:flutter/material.dart';

class CollectionsProvider extends ChangeNotifier {
  final _repository = CollectionRepository();
  final Map<CollectionType, Collection> _collections = {};
  final Map<CollectionType, bool> _hasFetched = {
    for (final type in CollectionType.values) type: false,
  };
  final Map<CollectionType, int> _page = {
    for (final type in CollectionType.values) type: 1,
  };
  final Map<CollectionType, bool> _hasMore = {
    for (final type in CollectionType.values) type: true,
  };
  final Map<CollectionType, bool> _isLoadingMore = {
    for (final type in CollectionType.values) type: false,
  };
  final int _limit = 15;

  Map<CollectionType, Collection> get collections => _collections;

  bool isLoadingMore(CollectionType type) => _isLoadingMore[type] ?? false;
  bool hasMore(CollectionType type) => _hasMore[type] ?? true;

  Future<void> fetchCollection(CollectionType type, [int page = 1]) async {
    if (!_hasFetched[type]! || page > 1) {
      final collection = await _repository.getCollections(type, page, _limit);

      if (_collections[type] == null) {
        _collections[type] = collection;
      } else {
        final existingIds =
            _collections[type]!.data.map((a) => a.uniqueId).toSet();
        final newItems =
            collection.data
                .where((a) => !existingIds.contains(a.uniqueId))
                .toList();

        _collections[type]!.data.addAll(newItems);
      }

      if (collection.data.length < _limit) {
        _hasMore[type] = false;
      }
      if (page == 1) {
        _hasFetched[type] = true;
      }
      _page[type] = page;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage(CollectionType type) async {
    if (_isLoadingMore[type]! || !_hasMore[type]!) return;

    _isLoadingMore[type] = true;
    notifyListeners();

    final nextPage = _page[type]! + 1;
    await fetchCollection(type, nextPage);

    _isLoadingMore[type] = false;
    notifyListeners();
  }

  Future<void> addToCollection(
    CollectionType type,
    Anime anime, [
    KodikResult? kodikResult,
  ]) async {
    final uniqueId = anime.uniqueId;

    for (final entry in _collections.entries) {
      entry.value.data.removeWhere((a) => a.uniqueId == uniqueId);
    }
    if (kodikResult != null && anime.release.shikimoriId != null) {
      await _repository.addToCollection(
        type,
        int.parse('$kodikIdPattern${anime.release.shikimoriId}'),
      );
    }
    if (anime.release.id != -1) {
      await _repository.addToCollection(type, anime.release.id);
    }

    final animeToAdd =
        kodikResult != null
            ? Anime.fromAnilibriaAndKodik(kodikResult, anime)
            : anime;

    if (_collections[type] == null) {
      await fetchCollection(type);
    } else {
      if (!_collections[type]!.data.any((a) => a.uniqueId == uniqueId)) {
        _collections[type]!.data.add(animeToAdd);
      }
    }

    notifyListeners();
  }

  CollectionType? getCollectionType(Anime anime) {
    final uniqueId = anime.uniqueId;
    for (final entry in _collections.entries) {
      if (entry.value.data.any((a) => a.uniqueId == uniqueId)) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> removeFromCollection(
    CollectionType type,
    Anime anime, [
    KodikResult? kodikResult,
  ]) async {
    final uniqueId = anime.uniqueId;

    for (final entry in _collections.entries) {
      entry.value.data.removeWhere((a) => a.uniqueId == uniqueId);
    }

    if (kodikResult != null && anime.release.shikimoriId != null) {
      await _repository.removeFromCollection(
        type,
        int.parse('$kodikIdPattern${anime.release.shikimoriId}'),
      );
    }
    if (anime.release.id != -1) {
      await _repository.removeFromCollection(type, anime.release.id);
    }

    if (_collections[type] != null) {
      _collections[type]!.data.removeWhere((a) => a.uniqueId == uniqueId);
    }

    notifyListeners();
  }
}
