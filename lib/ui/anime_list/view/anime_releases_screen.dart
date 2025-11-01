import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/models/search_anime.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/anime_list/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/search/widgets/widgets.dart';
import 'package:flutter/material.dart';

class AnimeReleasesScreen extends StatefulWidget {
  const AnimeReleasesScreen({super.key});

  @override
  State<AnimeReleasesScreen> createState() => _AnimeReleasesScreenState();
}

class _AnimeReleasesScreenState extends State<AnimeReleasesScreen> {
  List<SearchAnime>? _animeList;
  String? _query;
  final _textController = TextEditingController();
  late AnimeRepository repository;
  Mode? mode;
  bool _isLoading = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _fetchAnime() async {
    setState(() {
      _isLoading = true;
    });
    final animeList = await repository.getLatestReleases();
    if (mounted) {
      setState(() {
        _animeList = animeList;
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final List<SearchAnime>? releases = arguments['genreReleases'];
      final m = await ModeStorage.getMode();
      repository = AnimeRepository(mode: m);
      final query = arguments['query'] as String?;
      if (query != null) {
        setState(() {
          _isLoading = true;
        });
        final anime = await repository.searchAnime(query);
        setState(() {
          _animeList = anime;
          _query = query;
          _isLoading = false;
        });
      } else {
        setState(() {
          _animeList = releases;
        });
      }
      setState(() {
        mode = m;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body:
          _animeList == null || _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: LayoutBuilder(
                  builder: (contex, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    double screenWidth = MediaQuery.of(context).size.width;
                    final l10n = AppLocalizations.of(context)!;
                    int crossAxisCount = 2;
                    if (screenWidth >= 600) {
                      crossAxisCount = 3;
                    }
                    if (screenWidth >= 900) {
                      crossAxisCount = 4;
                    }

                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          SearchInput(
                            controller: _textController,
                            isWide: isWide,
                            onPressed: () async {
                              if (_textController.text.trim().isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final anime = await repository.searchAnime(
                                  _textController.text,
                                );
                                setState(() {
                                  _animeList = anime;
                                  _query = _textController.text;
                                  _isLoading = false;
                                });
                              } else {
                                _fetchAnime();
                              }
                            },
                            onSubmitted: (value) async {
                              if (value.trim().isNotEmpty) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final anime = await repository.searchAnime(
                                  value,
                                );
                                setState(() {
                                  _animeList = anime;
                                  _query = value;
                                  _isLoading = false;
                                });
                              } else {
                                _fetchAnime();
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Expanded(
                            child:
                                _animeList!.isEmpty
                                    ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.search_off,
                                            color: Colors.grey,
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            l10n.no_anime_found(_query ?? ''),
                                            style: const TextStyle(
                                              fontSize: 18,
                                              color: Colors.grey,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
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
                                      itemCount: _animeList!.length,
                                      itemBuilder: (context, index) {
                                        return AnimeCard(
                                          anime: _animeList![index],
                                          isWide: isWide,
                                        );
                                      },
                                    ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}
