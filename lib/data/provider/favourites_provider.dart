import 'package:anime_app/data/models/anime_release.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/data/repositories/user_repository.dart';

class FavouritesProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  List<AnimeRelease> _favourites = [];
  bool _hasFetched = false;

  List<AnimeRelease> get favourites => _favourites;

  Future<void> fetchFavourites() async {
    if (!_hasFetched) {
      _favourites = await _repository.getFavourites();
      _hasFetched = true;
      notifyListeners();
    }
  }

  bool isFavourite(int animeId) {
    return _favourites.any((anime) => anime.id == animeId);
  }

  Future<void> addToFavourites(AnimeRelease anime) async {
    await _repository.addToFavourite(anime.id);
    _favourites.add(anime);
    notifyListeners();
  }

  Future<void> removeFromFavourites(int animeId) async {
    await _repository.removeFromFavourites(animeId);
    _favourites.removeWhere((anime) => anime.id == animeId);
    notifyListeners();
  }

  Future<void> toggleFavourite(AnimeRelease anime) async {
    if (isFavourite(anime.id)) {
      await removeFromFavourites(anime.id);
    } else {
      await addToFavourites(anime);
    }
  }
}
