import 'dart:developer';
import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/models/login.dart';
import 'package:anime_app/data/models/timecode.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:anime_app/data/storage/token_storage.dart';

class UserRepository extends BaseRepository {
  UserRepository() : super(DioClient().dio);

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

  Future<List<AnimeRelease>> getFavourites() async {
    try {
      final response = await dio.get('accounts/users/me/favorites/releases');
      final data = response.data as Map<String, dynamic>;
      final favouritesData = data['data'] as List<dynamic>;

      final favourites =
          favouritesData
              .map((f) => AnimeRelease.fromJson(f as Map<String, dynamic>))
              .toList();

      return favourites;
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
}
