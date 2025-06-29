import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});
  group('History storage', () {
    final history = History(
      animeId: 1,
      lastWatchedEpisode: 10,
      isWatched: true,
    );
    test('history should be updated', () async {
      await HistoryStorage.updateHistory(history);
      final updatedHistory = await HistoryStorage.getHistory();
      expect(updatedHistory.first.animeId, history.animeId);
      expect(
        updatedHistory.first.lastWatchedEpisode,
        history.lastWatchedEpisode,
      );
      expect(updatedHistory.first.isWatched, history.isWatched);

      final anotherEpisodeHistory = history.copyWith(lastWatchedEpisode: 11);

      await HistoryStorage.updateHistory(anotherEpisodeHistory);

      final anotherHistory = await HistoryStorage.getHistory();

      expect(anotherHistory.length, 1);
    });

    test('history should be cleared', () async {
      await HistoryStorage.clearHistory();
      final clearedHistory = await HistoryStorage.getHistory();

      expect(clearedHistory.length, 0);
    });

    test('history should return correct episode index', () async {
      final index = 10;

      await HistoryStorage.updateHistory(history);
      final historyIndex = await HistoryStorage.getEpisodeIndex(
        history.animeId,
      );

      expect(historyIndex, index);
    });

    test('history should return 0 if there is no anime', () async {
      final historyIndex = await HistoryStorage.getEpisodeIndex(99999999999);

      expect(historyIndex, 0);
    });
  });
}
