import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/models/search_anime.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/router/no_animation_route.dart';
import 'package:anime_app/ui/anime_list/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:flutter/material.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List<SearchAnime>? _animeList;
  List<SearchAnime>? _recommendedList;
  Mode? mode;
  bool isLoading = true;
  late AnimeRepository repository;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final m = await ModeStorage.getMode();

      setState(() {
        mode = m;
        repository = AnimeRepository(mode: m);
      });
      _fetchAnime();
      setState(() {
        isLoading = false;
      });
    });
  }

  Future<void> _fetchAnime() async {
    final animeList = await repository.getLatestReleases();
    final recommendedReleases = await repository.getRecommendedAnime();
    if (mounted) {
      setState(() {
        _animeList = animeList;
        _recommendedList = recommendedReleases;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    int crossAxisCount = 2;
    if (screenWidth >= 600) {
      crossAxisCount = 3;
    }
    if (screenWidth >= 900) {
      crossAxisCount = 4;
    }

    return Scaffold(
      bottomNavigationBar: AnimeBar(isBlocked: isLoading),
      body:
          _animeList == null || _recommendedList == null || mode == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: ListView(
                    children: [
                      SizedBox(
                        height: 540,
                        width: double.infinity,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/images/mikasa.png',
                              fit: BoxFit.cover,
                            ),

                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        SizedBox(),
                                        Text(
                                          l10n.app_title.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 32,
                                            fontFamily: 'Allan',
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        PopupMenuButton<void>(
                                          icon: const Icon(
                                            Icons.person,
                                            size: 32,
                                          ),
                                          itemBuilder:
                                              (BuildContext context) => [
                                                PopupMenuItem<void>(
                                                  enabled: false,
                                                  child: StatefulBuilder(
                                                    builder: (
                                                      context,
                                                      setStatePopup,
                                                    ) {
                                                      return Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(l10n.anilibria),
                                                          Switch(
                                                            value:
                                                                mode ==
                                                                Mode.consumet,
                                                            onChanged: (
                                                              value,
                                                            ) async {
                                                              final newMode =
                                                                  value
                                                                      ? Mode
                                                                          .consumet
                                                                      : Mode
                                                                          .anilibria;
                                                              await ModeStorage.saveMode(
                                                                newMode,
                                                              );
                                                              setStatePopup(
                                                                () {},
                                                              );
                                                              setState(
                                                                () =>
                                                                    mode =
                                                                        newMode,
                                                              );
                                                              Navigator.of(
                                                                context,
                                                              ).pushReplacement(
                                                                NoAnimationPageRoute(
                                                                  builder:
                                                                      (
                                                                        context,
                                                                      ) =>
                                                                          AnimeListScreen(),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                          Text(l10n.subtitle),
                                                        ],
                                                      );
                                                    },
                                                  ),
                                                ),
                                              ],
                                          onSelected: (_) {},
                                        ),
                                      ],
                                    ),
                                    Text(
                                      l10n.app_name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 72,
                                        fontFamily: 'Allan',
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.0,
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          l10n.latest_releases.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      ReleasesCarousel(releases: _animeList!),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          l10n.recommended.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 2 / 3,
                        ),
                        itemCount: _recommendedList!.length,
                        itemBuilder: (context, index) {
                          return AnimeCard(anime: _recommendedList![index]);
                        },
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
