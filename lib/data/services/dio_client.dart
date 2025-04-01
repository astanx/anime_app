import 'dart:developer';
import 'package:dio/dio.dart';

class DioClient {
  Dio dio;

  DioClient()
    : dio = Dio(BaseOptions(baseUrl: 'https://api.anilibria.tv/v3/')) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
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
