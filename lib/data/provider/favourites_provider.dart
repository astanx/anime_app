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
      _favourites.addAll(newFavourites);
      _page = nextPage;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  bool isFavourite(int animeId) {
    return _favourites.any((anime) => anime.release.id == animeId);
  }

  bool isFavouriteKodik(String? shikimoriId) {
    return _favourites.any((anime) => anime.release.shikimoriId == shikimoriId);
  }

  Future<void> addToFavourites(Anime anime, [int? id]) async {
    await _repository.addToFavourite(id ?? anime.release.id);
    if (id == null && anime.release.shikimoriId != null) {
      final animeId = int.parse(
        '$kodikIdPattern${anime.release.kodikResult?.shikimoriId}',
      );
      await _repository.addToFavourite(animeId);
    }
    _favourites.add(anime);
    notifyListeners();
  }

  Future<void> removeFromFavourites(int animeId) async {
    await _repository.removeFromFavourites(animeId);
    _favourites.removeWhere((anime) => anime.release.id == animeId);
    notifyListeners();
  }

  Future<void> removeFromFavouritesKodik(String? shikimoriId) async {
    await _repository.removeFromFavourites(int.parse(shikimoriId ?? '0'));
    _favourites.removeWhere(
      (anime) => anime.release.shikimoriId == shikimoriId,
    );
    notifyListeners();
  }

  Future<void> toggleFavourite(Anime anime) async {
    if (isFavourite(anime.release.id)) {
      await removeFromFavourites(anime.release.id);
    } else {
      await addToFavourites(anime);
    }
  }

  Future<void> toggleKodikFavourite(Anime kodikAnime) async {
    final id = int.parse(
      '$kodikIdPattern${kodikAnime.release.kodikResult?.shikimoriId}',
    );
    final shikimoriId = kodikAnime.release.kodikResult?.shikimoriId;
    if (isFavouriteKodik(shikimoriId)) {
      await removeFromFavouritesKodik(shikimoriId);
    } else {
      await addToFavourites(kodikAnime, id);
    }
  }
}
