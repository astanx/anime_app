import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/history_repository.dart';
import 'package:flutter/material.dart';

class HistoryProvider extends ChangeNotifier {
  final Mode mode;

  late final HistoryRepository _repository;
  late final AnimeRepository _animeRepository;

  HistoryProvider({required this.mode}) {
    _repository = HistoryRepository(mode: mode);
    _animeRepository = AnimeRepository(mode: mode);
  }

  List<AnimeWithHistory> _history = [];
  bool _hasFetched = false;
  int _page = 1;
  final int _limit = 5;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  final Set<String> _existingIds = {};

  List<AnimeWithHistory>? get history => _history;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;

  Future<void> fetchHistory() async {
    if (_hasFetched) return;

    final historyPage = await _repository.getHistory(_page, _limit);

    if (historyPage.history.isEmpty) {
      _hasMore = false;
      notifyListeners();
      return;
    }

    for (var h in historyPage.history) {
      final anime = await _animeRepository.getAnimeById(h.animeID);
      if (anime != null) {
        _existingIds.add(h.animeID);
        _history.add(AnimeWithHistory(anime: anime, history: h));
      }
    }

    _hasFetched = true;

    notifyListeners();
  }

  Future<void> fetchNextPage() async {
    if (_isLoadingMore || !_hasMore) return;

    _isLoadingMore = true;
    notifyListeners();

    final historyPage = await _repository.getHistory(_page + 1, _limit);

    if (historyPage.history.isEmpty) {
      _hasMore = false;
    } else {
      for (var h in historyPage.history) {
        final anime = await _animeRepository.getAnimeById(h.animeID);
        if (anime != null) {
          _existingIds.add(h.animeID);
          _history.add(AnimeWithHistory(anime: anime, history: h));
        }
      }

      _page += 1;
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> addOrUpdateHistory(AnimeWithHistory historyAnime) async {
    _history.removeWhere((h) => h.anime.id == historyAnime.anime.id);
    _history.insert(0, historyAnime);

    final history = History(
      animeID: historyAnime.anime.id,
      lastWatchedEpisode: historyAnime.history.lastWatchedEpisode,
      isWatched: historyAnime.history.isWatched,
      watchedAt: historyAnime.history.watchedAt,
    );

    await _repository.addToHistory(history);
    notifyListeners();
  }
}
