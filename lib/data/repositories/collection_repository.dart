import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class CollectionRepository extends BaseRepository {
  final Mode mode;
  final AnimeRepository repository;

  CollectionRepository({required this.mode})
    : repository = AnimeRepository(mode: mode),
      super(DioClient().dio);

  Future<CollectionMeta> getCollection(
    CollectionType type,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        '/collection?type=${type.name}&page=$page&limit=$limit',
      );
      final data = response.data as Map<String, dynamic>;
      final collection = CollectionMeta.fromJson(data, type.name);

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCollection(CollectionType type, String animeID) async {
    try {
      final body = {'type': type.name, 'anime_id': animeID};
      dio.post('/collection', data: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeFromCollection(CollectionType type, String animeID) async {
    try {
      final body = {'anime_id': animeID, 'type': type.name};
      dio.delete('/collection', data: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<Collection?> getCollectionForAnime(String animeID) async {
    try {
      final response = await dio.get('/collection/anime?animeID=$animeID');
      final data = response.data as Map<String, dynamic>;
      if (data['anime_id'].isEmpty) {
        return null;
      }
      final collection = Collection.fromJson(data);

      return collection;
    } catch (e) {
      rethrow;
    }
  }
}
