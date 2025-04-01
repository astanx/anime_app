import 'package:dio/dio.dart';

abstract class BaseRepository {
  final Dio dio;

  BaseRepository(this.dio);
}
