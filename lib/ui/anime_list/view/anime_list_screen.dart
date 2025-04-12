import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/ui/anime_list/widgets/anime_card.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List<AnimeRelease>? _animeList;
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAnime();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    int crossAxisCount = 2;
    if (screenWidth >= 600) {
      crossAxisCount = 3;
    }
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    }

    return Scaffold(
      appBar: AnimeAppBar(title: 'Oshavotik'),
      body:
          _animeList == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: const InputDecoration(
                                labelText: 'Enter anime title',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              if (_textController.text == '') {
                                _fetchAnime();
                              } else {
                                final anime = await AnimeRepository()
                                    .searchAnime(_textController.text);

                                _animeList = anime;
                                setState(() {});
                              }
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2 / 5,
                              ),
                          itemCount: _animeList!.length,
                          itemBuilder: (context, index) {
                            return AnimeCard(anime: _animeList![index]);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Future<void> _fetchAnime() async {
    final animeList = await AnimeRepository().getReleases(20);

    if (mounted) {
      setState(() {
        _animeList = animeList;
      });
    }
  }
}
