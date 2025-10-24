import 'dart:developer';
import 'package:anime_app/data/models/device_id.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:anime_app/data/storage/id_storage.dart';
import 'package:dio/dio.dart';

class UserRepository extends BaseRepository {
  UserRepository() : super(DioClient().dio);

  Future<void> registerDevice() async {
    try {
      if (await IDStorage.getID() != null) return;

      final response = await dio.get('/users/device?from=app');
      final data = response.data;

      final device = DeviceID.fromJson(data);

      if (device.id.isNotEmpty) {
        await IDStorage.saveID(device.id);
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> checkAnilibriaServerStatus() async {
    try {
      final response = await Dio().get(
        'https://aniliberty.top/api/v1/app/status',
      );

      final data = response.data;

      log(data.toString());

      return data['is_alive'] ?? false;
    } catch (e) {
      return false;
    }
  }
}
