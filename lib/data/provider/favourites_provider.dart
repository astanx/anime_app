import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/data/repositories/user_repository.dart';

class FavouritesProvider extends ChangeNotifier {
  final UserRepository _repository = UserRepository();
  List<Anime> _favourites = [];
  bool _hasFetched = false;

  List<Anime> get favourites => _favourites;

  Future<void> fetchFavourites() async {
    if (!_hasFetched) {
      _favourites = await _repository.getFavourites();
      _hasFetched = true;
      notifyListeners();
    }
  }

  bool isFavourite(int animeId) {
    return _favourites.any((anime) => anime.release.id == animeId);
  }

  Future<void> addToFavourites(Anime anime) async {
    await _repository.addToFavourite(anime.release.id);
    _favourites.add(anime);
    notifyListeners();
  }

  Future<void> removeFromFavourites(int animeId) async {
    await _repository.removeFromFavourites(animeId);
    _favourites.removeWhere((anime) => anime.release.id == animeId);
    notifyListeners();
  }

  Future<void> toggleFavourite(Anime anime) async {
    if (isFavourite(anime.release.id)) {
      await removeFromFavourites(anime.release.id);
    } else {
      await addToFavourites(anime);
    }
  }
}
