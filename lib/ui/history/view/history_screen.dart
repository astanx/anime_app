import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:anime_app/ui/history/widgets/widgets.dart';
import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<AnimeWithHistory>? _historyList;

  Future<void> fetchHistory() async {
    final history = await HistoryStorage.getHistory();

    final futures =
        history.map((h) async {
          final anime = await AnimeRepository().getAnimeById(h.animeId);
          return AnimeWithHistory.combineWithHistory(anime: anime, history: h);
        }).toList();

    _historyList = await Future.wait(futures);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text('History'),
              ListView.builder(
                itemCount: _historyList!.length,
                itemBuilder: (context, index) {
                  return HistoryCard();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
