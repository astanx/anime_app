import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:flutter/material.dart';

class HistoryProvider extends ChangeNotifier {
  final _repository = AnimeRepository();
  bool _hasFetched = false;
  List<AnimeWithHistory>? _history;

  List<AnimeWithHistory>? get history => _history;

  Future<void> fetchHistory() async {
    if (_hasFetched) return;
    _hasFetched = true;
    final history = await HistoryStorage.getHistory();

    final futures =
        history
            .where(
              (h) =>
                  !(h.animeId.toString().startsWith(kodikIdPattern) &&
                      !isTurnedKodik),
            )
            .map((h) async {
              if (h.animeId.toString().startsWith(kodikIdPattern) &&
                  h.kodikResult?.shikimoriId != null &&
                  isTurnedKodik) {
                final shikimori = await _repository.getShikimoriAnimeById(
                  h.kodikResult!.shikimoriId!,
                );
                return AnimeWithHistory.combineWithHistory(
                  anime: Anime.fromKodikAndShikimori(h.kodikResult!, shikimori),
                  history: h,
                );
              }
              final anime = await _repository.getAnimeById(h.animeId);
              return AnimeWithHistory.combineWithHistory(
                anime: anime,
                history: h,
              );
            })
            .toList();

    _history = await Future.wait(futures);
    notifyListeners();
  }

  Future<void> updateHistory(AnimeWithHistory historyAnime) async {
    if (_history == null) {
      await fetchHistory();
    }
    _history!.removeWhere((h) {
      return h.anime.uniqueId == historyAnime.anime.uniqueId;
    });

    _history!.add(historyAnime);
    final history = History(
      animeId: historyAnime.anime.uniqueId,
      lastWatchedEpisode: historyAnime.lastWatchedEpisode,
      isWatched: historyAnime.isWatched,
      kodikResult: isTurnedKodik ? historyAnime.kodikResult : null,
    );
    await HistoryStorage.updateHistory(history);
    notifyListeners();
  }
}
