import 'package:anime_app/data/models/anime_release.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/repositories/user_repository.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/anime_list/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:flutter/material.dart';

class AnimeListScreen extends StatefulWidget {
  const AnimeListScreen({super.key});

  @override
  State<AnimeListScreen> createState() => _AnimeListScreenState();
}

class _AnimeListScreenState extends State<AnimeListScreen> {
  List<AnimeRelease>? _animeList;
  List<AnimeRelease>? _weekSchedule;
  List<Genre>? _genres;
  bool isLoading = true;
  final repository = AnimeRepository();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fetchAnime();
    _fetchGenres();
    setState(() {
      isLoading = false;
    });
  }

  Future<void> _fetchAnime() async {
    final animeList = await repository.getReleases(20);
    final weekSchedule = await repository.getWeekSchedule();
    if (mounted) {
      setState(() {
        _animeList = animeList;
        _weekSchedule = weekSchedule;
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
          _animeList == null
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
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(
                                            Icons.person,
                                            size: 32,
                                          ),
                                          itemBuilder:
                                              (BuildContext context) => [
                                                PopupMenuItem<String>(
                                                  value: 'exit',
                                                  child: ListTile(
                                                    leading: Icon(
                                                      Icons.exit_to_app,
                                                    ),
                                                    title: Text(l10n.exit),
                                                  ),
                                                ),
                                              ],
                                          onSelected: (String value) {
                                            if (value == 'exit') {
                                              UserRepository().logout();
                                              Navigator.of(
                                                context,
                                              ).pushNamed('/');
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                    Text(
                                      l10n.app_name.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 72,

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
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10.0,
                          top: 20.0,
                          bottom: 10.0,
                        ),
                        child: Text(
                          l10n.this_week.toUpperCase(),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ),
                      ReleasesCarousel(releases: _weekSchedule!),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          l10n.genres.toUpperCase(),
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
