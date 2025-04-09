import 'dart:developer';
import 'package:anime_app/data/models/login.dart';
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
}
