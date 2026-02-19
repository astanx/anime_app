import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/collection_repository.dart';
import 'package:flutter/material.dart';

class CollectionsProvider extends ChangeNotifier {
  final Mode mode;

  late final CollectionRepository _repository;
  late final AnimeRepository _animeRepository;

  CollectionsProvider({required this.mode}) {
    _repository = CollectionRepository(mode: mode);
    _animeRepository = AnimeRepository(mode: mode);
  }
  final Set<String> _existingIds = {};
  final Map<CollectionType, List<Anime>> _collections = {};
  final Map<CollectionType, bool> _hasFetched = {
    for (final type in CollectionType.values) type: false,
  };
  Map<CollectionType, bool> get hasFetched => _hasFetched;
  final Map<CollectionType, int> _page = {
    for (final type in CollectionType.values) type: 1,
  };
  final Map<CollectionType, bool> _hasMore = {
    for (final type in CollectionType.values) type: true,
  };
  final Map<CollectionType, bool> _isLoadingMore = {
    for (final type in CollectionType.values) type: false,
  };
  final int _limit = 5;

  Map<CollectionType, List<Anime>> get collections => _collections;

  bool isLoadingMore(CollectionType type) => _isLoadingMore[type] ?? false;
  bool hasMore(CollectionType type) => _hasMore[type] ?? true;

  Future<void> fetchCollection(CollectionType type, [int page = 1]) async {
    if (!_hasFetched[type]! || page > 1) {
      final collection = await _repository.getCollection(type, page, _limit);
      if (_collections[type] == null) {
        final futures = collection.animeIDs.map((id) {
          if (_existingIds.contains(id)) {
            return Future<Anime?>.value(null);
          }
          _existingIds.add(id);
          return _animeRepository.getAnimeById(id);
        });
        final anime = await Future.wait(futures);
        _collections[type] = anime.whereType<Anime>().toList();
      } else {
        final futures = collection.animeIDs.map((id) {
          if (_existingIds.contains(id)) {
            return Future<Anime?>.value(null);
          }
          _existingIds.add(id);
          return _animeRepository.getAnimeById(id);
        });
        final newItems = await Future.wait(futures);

        _collections[type]!.addAll(newItems.whereType<Anime>());
      }

      if (collection.animeIDs.length < _limit) {
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
    for (final entry in _collections.entries) {
      entry.value.removeWhere((a) => a.id == anime.id);
    }
    if (!_existingIds.contains(anime.id)) {
      _existingIds.add(anime.id);
    }

    await _repository.addToCollection(type, anime.id);

    if (_collections[type] == null) {
      await fetchCollection(type);
      _collections[type]!.insert(0, anime);
    } else {
      if (!_collections[type]!.any((a) => a.id == anime.id)) {
        _collections[type]!.insert(0, anime);
      }
    }

    notifyListeners();
  }

  CollectionType? getCollectionType(Anime anime) {
    for (final entry in _collections.entries) {
      if (entry.value.any((a) => a.id == anime.id)) {
        return entry.key;
      }
    }
    return null;
  }

  Future<void> removeFromCollection(CollectionType type, Anime anime) async {
    for (final entry in _collections.entries) {
      entry.value.removeWhere((a) => a.id == anime.id);
    }

    _existingIds.remove(anime.id);
    await _repository.removeFromCollection(type, anime.id);

    if (_collections[type] != null) {
      _collections[type]!.removeWhere((a) => a.id == anime.id);
    }

    notifyListeners();
  }

  Future<CollectionType?> fetchCollectionForAnime(Anime anime) async {
    if (_existingIds.contains(anime.id)) {
      return getCollectionType(anime);
    }
    final collection = await _repository.getCollectionForAnime(anime.id);
    if (collection == null) {
      return null;
    }

    return collection.type;
  }
}
