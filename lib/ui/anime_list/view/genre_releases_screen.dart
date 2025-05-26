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
  String? _query;
  final repository = AnimeRepository();
  final _textController = TextEditingController();

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnime() async {
    final animeList = await repository.getReleases(20);

    if (mounted) {
      setState(() {
        _genreReleases = animeList;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final List<AnimeRelease>? releases = arguments['genreReleases'];

      final query = arguments['query'] as String?;
      if (query != null) {
        final anime = await repository.searchAnime(query);
        setState(() {
          _genreReleases = anime;
          _query = query;
        });
      } else {
        setState(() {
          _genreReleases = releases;
        });
      }
    });
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
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) async {
                                if (value.trim().isNotEmpty) {
                                  final anime = await repository.searchAnime(
                                    value,
                                  );
                                  setState(() {
                                    _genreReleases = anime;
                                    _query = value;
                                  });
                                } else {
                                  _fetchAnime();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              if (_textController.text.trim().isNotEmpty) {
                                final anime = await repository.searchAnime(
                                  _textController.text,
                                );
                                setState(() {
                                  _genreReleases = anime;
                                  _query = _textController.text;
                                });
                              } else {
                                _fetchAnime();
                              }
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child:
                            _genreReleases!.isEmpty
                                ? Center(
                                  child: Text(
                                    'No anime found${_query != null && _query!.isNotEmpty ? ' for "$_query"' : ''}.',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.grey,
                                    ),
                                  ),
                                )
                                : GridView.builder(
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 2 / 4,
                                      ),
                                  itemCount: _genreReleases!.length,
                                  itemBuilder: (context, index) {
                                    return AnimeCard(
                                      anime: _genreReleases![index],
                                    );
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
