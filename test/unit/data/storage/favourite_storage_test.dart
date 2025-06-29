import 'package:anime_app/data/storage/favourites_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Favourite storage', () {
    final id = 1;
    test('favourite should update', () async {
      await FavouritesStorage.updateFavorites(id);
      final updatedFavourites = await FavouritesStorage.getFavoritesIds();
      expect(updatedFavourites.first, id);
    });

    test('favourite should clear', () async {
      final updatedFavourites = await FavouritesStorage.getFavoritesIds();
      expect(updatedFavourites.length, greaterThan(0));
      await FavouritesStorage.clearFavourites();

      final clearedFavourites = await FavouritesStorage.getFavoritesIds();
      expect(clearedFavourites.length, 0);
    });

    test('favourite should be deleted', () async {
      await FavouritesStorage.updateFavorites(id);

      await FavouritesStorage.updateFavorites(id);
      final updatedFavourites = await FavouritesStorage.getFavoritesIds();
      expect(updatedFavourites.length, 0);
    });
  });
}
