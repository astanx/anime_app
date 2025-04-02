import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/ui/anime_list/widgets/widgets.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List<Anime>? _animeList;

  @override
  void initState() {
    _fetchAnime();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Anime List')),
      body: _animeList == null
          ? const Center(child: CircularProgressIndicator())
          : ListView.separated(
              itemCount: _animeList!.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (_, index) => AnimeCard(anime: _animeList![index]),
            ),
    );
  }

  Future<void> _fetchAnime() async {
    _animeList = await AnimeRepository().getReleases(20);
    setState(() {});
  }
}
