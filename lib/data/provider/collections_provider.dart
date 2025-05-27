import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
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
        _collections[type]!.data.addAll(collection.data);
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
      await fetchCollection(type);
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

  CollectionType? getKodikCollectionType(Anime anime) {
    for (final entry in _collections.entries) {
      if (entry.value.data.any(
        (a) => a.release.shikimoriId == anime.release.shikimoriId,
      )) {
        return entry.key;
      }
    }
    return null;
  }
}
