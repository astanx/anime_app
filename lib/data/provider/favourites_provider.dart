import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/favourite_repository.dart';
import 'package:flutter/material.dart';

class FavouritesProvider extends ChangeNotifier {
  final Mode mode;

  late final FavouriteRepository _repository;
  late final AnimeRepository _animeRepository;

  FavouritesProvider({required this.mode}) {
    _repository = FavouriteRepository(mode: mode);
    _animeRepository = AnimeRepository(mode: mode);
  }

  List<Anime> _favourites = [];
  bool _hasFetched = false;
  int _page = 1;
  final int _limit = 5;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final Set<String> _existingIds = {};

  List<Anime> get favourites => _favourites;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> fetchFavourites() async {
    if (!_hasFetched) {
      final favourites = await _repository.getFavourites(_page, _limit);
      final futures = favourites.animeIDs.map((id) {
        _existingIds.add(id);

        return _animeRepository.getAnimeById(id);
      });

      _hasFetched = true;

      _favourites = await Future.wait(futures);

      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final newFavourites = await _repository.getFavourites(nextPage, _limit);

    if (newFavourites.animeIDs.isEmpty) {
      _hasMore = false;
    } else {
      final uniqueNew =
          newFavourites.animeIDs
              .where((id) => !_existingIds.contains(id))
              .toList();

      final futures = uniqueNew.map((id) {
        _existingIds.add(id);
        return _animeRepository.getAnimeById(id);
      });

      final uniqueAnime = await Future.wait(futures);
      _favourites.addAll(uniqueAnime);
      _page = nextPage;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  bool isFavourite(Anime anime) {
    return _favourites.any((a) => a.id == anime.id);
  }

  Future<void> addToFavourites(Anime anime) async {
    if (_favourites.any((a) => a.id == anime.id)) {
      return;
    }
    await _repository.addToFavourite(anime.id);

    _favourites.add(anime);

    notifyListeners();
  }

  Future<void> removeFromFavourites(Anime anime) async {
    await _repository.removeFromFavourites(anime.id);

    _favourites.removeWhere((a) => a.id == anime.id);
    notifyListeners();
  }

  Future<void> toggleFavourite(Anime anime) async {
    if (isFavourite(anime)) {
      await removeFromFavourites(anime);
    } else {
      await addToFavourites(anime);
    }
  }
}
