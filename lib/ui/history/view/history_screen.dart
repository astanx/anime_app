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
  final repository = AnimeRepository();
  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    final history = await HistoryStorage.getHistory();

    final futures =
        history.map((h) async {
          final anime = await repository.getAnimeById(h.animeId);
          return AnimeWithHistory.combineWithHistory(anime: anime, history: h);
        }).toList();

    final results = await Future.wait(futures);

    setState(() {
      _historyList = results.reversed.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _historyList == null
                  ? const Center(child: CircularProgressIndicator())
                  : _historyList!.isEmpty
                  ? const Center(child: Text('No history found.'))
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _historyList!.length,
                          itemBuilder: (context, index) {
                            return HistoryCard(anime: _historyList![index]);
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
