import 'dart:developer';
import 'package:anime_app/data/storage/token_storage.dart';
import 'package:dio/dio.dart';

class DioClient {
  Dio dio;

  DioClient()
    : dio = Dio(BaseOptions(baseUrl: 'https://anilibria.top/api/v1/')) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await TokenStorage.getToken();

          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
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
