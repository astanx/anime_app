import 'dart:developer';
import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/storage/id_storage.dart';
import 'package:dio/dio.dart';

class DioClient {
  Dio dio;

  DioClient() : dio = Dio(BaseOptions(baseUrl: '$baseUrl/api/v1')) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final deviceID = await IDStorage.getID();
          if (deviceID != null) {
            options.headers['Authorization'] = 'Device $deviceID';
          }
          log('Request to: ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          log('Response: ${response.data}');
          return handler.next(response);
        },
        onError: (DioException e, handler) {
          log('Error: ${e.message}');
          return handler.next(e);
        },
      ),
    );
  }
}
