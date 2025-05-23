import 'dart:developer';
import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/login.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:anime_app/data/storage/token_storage.dart';

class UserRepository extends BaseRepository {
  UserRepository() : super(DioClient().dio);
  final repository = AnimeRepository();

  Future<bool> login(String login, String password) async {
    try {
      final response = await dio.post(
        'accounts/users/auth/login',
        data: {'login': login, 'password': password},
      );
      final data = response.data;

      log(data.toString());

      final authData = Login.fromJson(data);

      if (authData.token.isNotEmpty) {
        await TokenStorage.saveToken(authData.token);

        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final response = await dio.post('accounts/users/auth/logout');

      final data = response.data;

      log(data.toString());

      await TokenStorage.clearToken();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateTimecode(List<Timecode> timecodes) async {
    try {
      final body = timecodes.map((t) => t.toJson()).toList();

      final response = await dio.post(
        'accounts/users/me/views/timecodes',
        data: body,
      );

      final data = response.data as List<dynamic>;

      log(data.toString());
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Timecode>> getTimecodes() async {
    try {
      final response = await dio.get('accounts/users/me/views/timecodes');
      final data = response.data as List<dynamic>;

      final timecodes = data.map((t) => Timecode.fromJson(t as List)).toList();
      return timecodes;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToFavourite(int animeId) async {
    try {
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

  Future<List<Anime>> getFavourites() async {
    try {
      final favourites = await getFavourites();
      final favouriteIds = favourites.map((a) => a.release.id).toSet();

      final kodikCollections = await getKodikCollectionIds();

      final missingKodikIds =
          kodikCollections
              .where((c) => !favouriteIds.contains(c.id))
              .map((c) => c.id)
              .toList();

      final kodikAnimes = <Anime>[];

      for (final fullId in missingKodikIds) {
        final fullIdStr = fullId.toString();
        final patternStr = kodikIdPattern.toString();

        if (fullIdStr.startsWith(patternStr)) {
          final kodikResultIdStr = fullIdStr.substring(patternStr.length);
          final kodikResultId = int.parse(kodikResultIdStr);

          final kodikResults = await repository.getAnimeByKodikId(
            kodikResultId,
          );

          if (kodikResults.isNotEmpty) {
            final anime = Anime.fromKodik(kodikResults.first);
            kodikAnimes.add(anime);
          }
        }
      }

      return [...favourites, ...kodikAnimes];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromFavourites(int animeId) async {
    try {
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

  Future<Collection> getCollections(
    CollectionType type,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        'accounts/users/me/collections/releases?type_of_collection=${type.asQueryParam}&page=$page&limit=$limit',
      );
      final data = response.data as Map<String, dynamic>;

      final collection = Collection.fromJson(data);

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCollection(CollectionType type, int releaseId) async {
    try {
      final body = [
        {
          'type_of_collection': type.name.toUpperCase(),
          'release_id': releaseId,
        },
      ];
      dio.post('accounts/users/me/collections', data: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<CollectionId>> getKodikCollectionIds() async {
    try {
      final response = await dio.get('accounts/users/me/collections/ids');
      final data = response.data as List<dynamic>;

      final collection =
          data
              .map((entry) => CollectionId.fromList(entry as List<dynamic>))
              .where((c) => c.id.toString().startsWith(kodikIdPattern))
              .toList();

      return collection;
    } catch (e) {
      rethrow;
    }
  }
}
