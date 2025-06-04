import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/anime_list/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List<AnimeRelease>? _animeList;
  List<Genre>? _genres;
  final repository = AnimeRepository();
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
    _fetchGenres();
    Provider.of<TimecodeProvider>(context, listen: false).fetchTimecodes();
    Provider.of<FavouritesProvider>(context, listen: false).fetchFavourites();
    for (final type in CollectionType.values) {
      Provider.of<CollectionsProvider>(
        context,
        listen: false,
      ).fetchCollection(type, 1);
    }
  }

  Future<void> _fetchAnime() async {
    final animeList = await repository.getReleases(20);

    if (mounted) {
      setState(() {
        _animeList = animeList;
      });
    }
  }

  Future<void> _fetchGenres() async {
    final genres = await repository.getGenres(8);

    if (mounted) {
      setState(() {
        _genres = genres;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context);
    int crossAxisCount = 2;
    if (screenWidth >= 600) {
      crossAxisCount = 3;
    }
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    }

    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body:
          _animeList == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _textController,
                              decoration: InputDecoration(
                                labelText: l10n!.anime_search_placeholder,
                                border: OutlineInputBorder(),
                              ),
                              textInputAction: TextInputAction.search,
                              onSubmitted: (value) async {
                                if (value.trim().isEmpty) {
                                  return;
                                } else {
                                  final anime = await AnimeRepository()
                                      .searchAnime(value);
                                  Navigator.of(context).pushNamed(
                                    '/genre/releases',
                                    arguments: {'genreReleases': anime},
                                  );
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          IconButton(
                            onPressed: () async {
                              if (_textController.text.trim().isEmpty) {
                                return;
                              } else {
                                Navigator.of(context).pushNamed(
                                  '/genre/releases',
                                  arguments: {'query': _textController.text},
                                );
                              }
                            },
                            icon: const Icon(Icons.search),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ReleasesCarousel(releases: _animeList!),
                      const SizedBox(height: 20),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _genres!.length,
                        itemBuilder: (context, index) {
                          return GenreCard(genre: _genres![index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
