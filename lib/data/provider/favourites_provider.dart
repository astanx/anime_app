import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/repositories/favourite_repository.dart';
import 'package:flutter/material.dart';

class FavouritesProvider extends ChangeNotifier {
  final _repository = FavouriteRepository();
  List<Anime> _favourites = [];
  bool _hasFetched = false;
  int _page = 1;
  final int _limit = 15;
  bool _isLoadingMore = false;
  bool _hasMore = true;

  List<Anime> get favourites => _favourites;

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> fetchFavourites() async {
    if (!_hasFetched) {
      _favourites = await _repository.getFavourites(_page, _limit);
      _hasFetched = true;
      notifyListeners();
    }
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final nextPage = _page + 1;
    final newFavourites = await _repository.getFavourites(nextPage, _limit);

    if (newFavourites.isEmpty) {
      _hasMore = false;
    } else {
      final existingIds = _favourites.map((a) => a.uniqueId).toSet();
      final uniqueNew =
          newFavourites
              .where((a) => !existingIds.contains(a.uniqueId))
              .toList();

      _favourites.addAll(uniqueNew);
      _page = nextPage;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  bool isFavourite(Anime anime) {
    return _favourites.any((a) => a.uniqueId == anime.uniqueId);
  }

  Future<void> addToFavourites(Anime anime) async {
    final uniqueId = anime.uniqueId;

    if (anime.kodikResult != null) {
      await _repository.addToFavourite(
        int.parse('$kodikIdPattern${anime.release.shikimoriId}'),
      );
    }
    if (anime.release.id != -1) {
      await _repository.addToFavourite(anime.release.id);
    }

    if (!_favourites.any((a) => a.uniqueId == uniqueId)) {
      _favourites.add(anime);
    }

    notifyListeners();
  }

  Future<void> removeFromFavourites(Anime anime) async {
    final uniqueId = anime.uniqueId;
    if (anime.kodikResult != null) {
      await _repository.removeFromFavourites(
        int.parse('$kodikIdPattern${anime.release.shikimoriId}'),
      );
    }
    if (anime.release.id != -1) {
      await _repository.removeFromFavourites(anime.release.id);
    }
    _favourites.removeWhere((a) => a.uniqueId == uniqueId);
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
