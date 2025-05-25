import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';

class CollectionRepository extends BaseRepository {
  CollectionRepository() : super(DioClient().dio);
  final repository = AnimeRepository();

  Future<Collection> getCollections(
    CollectionType type,
    int page,
    int limit,
  ) async {
    try {
      final response = await dio.get(
        'accounts/users/me/collections/releases?type_of_collection=${type.asQueryParam}&page=$page&limit=$limit',
      );
      final data = response.data as Map<String, dynamic>;

      final collection = Collection.fromJson(data);

      final kodikIds = await getKodikCollectionIds(type);
      final kodikAnimes = <Anime>[];

      for (final id in kodikIds) {
        final fullIdStr = id.toString();
        final kodikResultIdStr = fullIdStr.substring(kodikIdPattern.length);
        final kodikResultId = int.parse(kodikResultIdStr);

        final kodikResults = await repository.getAnimeByKodikId(kodikResultId);
        final shikimoriResult = await repository.getShikimoriAnimeById(
          kodikResultId.toString(),
        );

        if (kodikResults.isNotEmpty) {
          final anime = Anime.fromKodikAndShikimori(
            kodikResults.first,
            shikimoriResult,
          );
          kodikAnimes.add(anime);
        }
      }

      collection.data.addAll(kodikAnimes);

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCollection(CollectionType type, int releaseId) async {
    try {
      final body = [
        {
          'type_of_collection': type.name.toUpperCase(),
          'release_id': releaseId,
        },
      ];
      dio.post('accounts/users/me/collections', data: body);
      return;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<int>> getKodikCollectionIds(CollectionType type) async {
    try {
      final response = await dio.get('accounts/users/me/collections/ids');
      final data = response.data as List<dynamic>;

      final collection =
          data
              .map((entry) => CollectionId.fromList(entry as List<dynamic>))
              .where((c) => c.id.toString().startsWith(kodikIdPattern))
              .where((c) => c.status == type.name.toUpperCase())
              .map((c) => c.id)
              .toList();

      return collection;
    } catch (e) {
      rethrow;
    }
  }
}
