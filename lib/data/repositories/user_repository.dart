import 'dart:developer';
import 'package:anime_app/data/models/login.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class UserRepository extends BaseRepository {
  UserRepository() : super(DioClient().dio);

  Future<Login> login(String login, String password) async {
    try {
      final response = await dio.post(
        'accounts/users/auth/login',
        data: {'login': login, 'password': password},
      );
      final data = response.data;

      log(data.toString());

      final authData = Login.fromJson(data);

      return authData;
    } catch (e) {
      rethrow;
    }
  }
}
