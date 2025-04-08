import 'dart:developer';
import 'package:anime_app/data/models/auth_url.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class UserRepository extends BaseRepository {
  UserRepository() : super(DioClient().dio);

  Future<AuthUrl> getAuthUrl(String provider) async {
    try {
      final response = await dio.get(
        'accounts/users/auth/social/$provider/login',
      );
      final data = response.data;

      log(data.toString());

      final authData = AuthUrl.fromJson(data);

      return authData;
    } catch (e) {
      rethrow;
    }
  }
}
