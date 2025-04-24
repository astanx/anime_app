import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/ui/anime_list/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:flutter/material.dart';

class GenreReleasesScreen extends StatefulWidget {
  const GenreReleasesScreen({super.key});

  @override
  State<GenreReleasesScreen> createState() => _GenreReleasesScreenState();
}

class _GenreReleasesScreenState extends State<GenreReleasesScreen> {
  List<AnimeRelease>? _genreReleases;

  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final List<AnimeRelease> releases =
        arguments['genreReleases'] as List<AnimeRelease>;
    setState(() {
      _genreReleases = releases;
    });
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
          _genreReleases == null
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
                              final anime = await AnimeRepository().searchAnime(
                                _textController.text,
                              );

                              _genreReleases = anime;
                              setState(() {});
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 2 / 5,
                              ),
                          itemCount: _genreReleases!.length,
                          itemBuilder: (context, index) {
                            return AnimeCard(anime: _genreReleases![index]);
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
