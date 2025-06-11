import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:anime_app/data/storage/favourites_storage.dart';

class FavouriteRepository extends BaseRepository {
  FavouriteRepository() : super(DioClient().dio);
  final repository = AnimeRepository();

  Future<void> addToFavourite(int animeId) async {
    try {
      if (animeId.toString().startsWith(kodikIdPattern)) {
        FavouritesStorage.updateFavorites(animeId);
      }
      final body = [
        {'release_id': animeId},
      ];
      final response = await dio.post(
        'accounts/users/me/favorites',
        data: body,
      );
      if (response.statusCode == 200) {
        return;
      }
      throw Error();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Anime>> getFavourites(int page, int limit) async {
    try {
      final response = await dio.get(
        'accounts/users/me/favorites/releases?page=$page&limit=$limit',
      );
      final data = response.data['data'] as List<dynamic>;
      var favourites = data.map((f) => Anime.fromJson(f)).toList();
      final kodikFavouritesIds = await getKodikFavouritesIds();

      final kodikResults = <KodikResult>[];

      for (final fullId in kodikFavouritesIds) {
        final fullIdStr = fullId.toString();
        final kodikResultIdStr = fullIdStr.substring(kodikIdPattern.length);
        final kodikResultId = int.parse(kodikResultIdStr);

        final kodikAnime = await repository.getAnimeByKodikId(kodikResultId);

        kodikResults.add(kodikAnime.first);
      }

      final matchResult = repository.matchAnimeWithKodik(
        favourites,
        kodikResults,
      );

      favourites = matchResult.matched;

      for (final remainingKodik in matchResult.unmatched) {
        if (remainingKodik.shikimoriId != null) {
          final shikimoriResult = await repository.getShikimoriAnimeById(
            remainingKodik.shikimoriId!,
          );
          final anime = Anime.fromKodikAndShikimori(
            remainingKodik,
            shikimoriResult,
          );
          favourites.add(anime);
        } else {
          final anime = Anime.fromKodik(remainingKodik);
          favourites.add(anime);
        }
      }

      return favourites;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavourites(int animeId) async {
    try {
      if (animeId.toString().startsWith(kodikIdPattern)) {
        FavouritesStorage.updateFavorites(animeId);
      }
      final body = [
        {'release_id': animeId},
      ];
      final response = await dio.delete(
        'accounts/users/me/favorites',
        data: body,
      );
      if (response.statusCode == 200) {
        return;
      }
      throw Error();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> getKodikFavouritesIds() async {
    try {
      final response = await dio.get('accounts/users/me/favorites/ids');
      final data = response.data as List<dynamic>;

      final favouritesIds =
          data
              .where((id) => id.toString().startsWith(kodikIdPattern))
              .map((id) => id as int)
              .toList();
      final ids = await FavouritesStorage.getFavoritesIds();

      return [...favouritesIds, ...ids];
    } catch (e) {
      rethrow;
    }
  }
}
