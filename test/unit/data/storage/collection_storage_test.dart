import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/storage/collection_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Collection storage', () {
    final status = CollectionType.planned;
    final collection = CollectionId(id: 1, status: status.asQueryParam);
    test('collection should update', () async {
      await CollectionStorage.updateCollection(collection.id, status);
      final updatedCollection = await CollectionStorage.getCollectionIds();
      expect(updatedCollection.first.id, collection.id);
      expect(updatedCollection.first.status, collection.status);
    });

    test('collection should clear', () async {
      final updatedCollection = await CollectionStorage.getCollectionIds();
      expect(updatedCollection.length, greaterThan(0));
      await CollectionStorage.clearCollections();

      final clearedCollection = await CollectionStorage.getCollectionIds();
      expect(clearedCollection.length, 0);
    });

    test('collection should change type', () async {
      final anotherStatus = CollectionType.watched;
      await CollectionStorage.updateCollection(collection.id, anotherStatus);

      final updatedCollection = await CollectionStorage.getCollectionIds();
      expect(updatedCollection.first.id, collection.id);
      expect(updatedCollection.first.status, anotherStatus.asQueryParam);
    });
  });
}
