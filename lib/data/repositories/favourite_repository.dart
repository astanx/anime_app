import 'package:anime_app/data/models/favourite.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class FavouriteRepository extends BaseRepository {
  final Mode mode;
  final AnimeRepository repository;

  FavouriteRepository({required this.mode})
    : repository = AnimeRepository(mode: mode),
      super(DioClient().dio);

  Future<void> addToFavourite(String animeID) async {
    try {
      final body = {'anime_id': animeID};
      await dio.post('/favourite', data: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<FavouriteMeta> getFavourites(int page, int limit) async {
    try {
      final response = await dio.get('/favourite?page=$page&limit=$limit');
      final data = response.data;
      final favourites = FavouriteMeta.fromJson(data);

      return favourites;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavourites(String animeID) async {
    try {
      final body = {'anime_id': animeID};
      await dio.delete('/favourite', data: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<Favourite?> getFavouriteForAnime(String animeID) async {
    try {
      final response = await dio.get('/favourite/anime?animeID=$animeID');
      final data = response.data;
      if (data['anime_id'].isEmpty) {
        return null;
      }
      final favourite = Favourite.fromJson(data);
      return favourite;
    } catch (e) {
      rethrow;
    }
  }
}
