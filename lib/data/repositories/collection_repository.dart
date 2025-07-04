import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/base_repository.dart';
import 'package:anime_app/data/services/dio_client.dart';
import 'package:anime_app/data/storage/collection_storage.dart';

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
      final kodikResults = <KodikResult>[];
      for (final id in kodikIds) {
        final fullIdStr = id.toString();
        final kodikResultIdStr = fullIdStr.substring(kodikIdPattern.length);
        final kodikResultId = int.parse(kodikResultIdStr);
        final results = await repository.getAnimeByKodikId(kodikResultId);
        if (results.isNotEmpty) {
          kodikResults.add(results.first);
        }
      }

      final matchResult = repository.matchAnimeWithKodik(
        collection.data,
        kodikResults,
      );
      collection.data = matchResult.matched;

      for (final remainingKodik in matchResult.unmatched) {
        if (remainingKodik.shikimoriId != null) {
          final shikimoriResult = await repository.getShikimoriAnimeById(
            remainingKodik.shikimoriId!,
          );
          final anime = Anime.fromKodikAndShikimori(
            remainingKodik,
            shikimoriResult,
          );
          collection.data.add(anime);
        } else {
          final anime = Anime.fromKodik(remainingKodik);
          collection.data.add(anime);
        }
      }

      return collection;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addToCollection(CollectionType type, int releaseId) async {
    try {
      if (releaseId.toString().startsWith(kodikIdPattern)) {
        CollectionStorage.updateCollection(releaseId, type);
      }
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

      final apiCollectionIds =
          data
              .map((entry) => CollectionId.fromList(entry as List<dynamic>))
              .where((c) => c.id.toString().startsWith(kodikIdPattern))
              .where((c) => c.status == type.name.toUpperCase())
              .map((c) => c.id)
              .toSet();

      final storageCollectionIds = await CollectionStorage.getCollectionIds();
      final storageIds =
          storageCollectionIds
              .where((c) => c.status == type.asQueryParam.toUpperCase())
              .map((c) => c.id)
              .toSet();

      final combinedIds = [...apiCollectionIds, ...storageIds].toSet().toList();

      return combinedIds;
    } catch (e) {
      rethrow;
    }
  }
}
