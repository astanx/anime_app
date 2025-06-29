import 'package:anime_app/data/storage/token_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('Token storage', () {
    final token = 'token';
    test('token should be saved', () async {
      await TokenStorage.saveToken(token);
      final savedToken = await TokenStorage.getToken();
      expect(savedToken, token);
    });

    test('token should be cleared', () async {
      await TokenStorage.clearToken();
      final savedToken = await TokenStorage.getToken();
      expect(savedToken, null);
    });
  });
}
