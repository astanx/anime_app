import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/models/search_anime.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/data/storage/translate_storage.dart';
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
  late String translateLang;
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
      translateLang = await TranslateStorage().getLanguage() ?? '';

      setState(() {
        mode = m;
        repository = AnimeRepository(mode: m);
      });
      await _fetchAnime();
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
    return Scaffold(
      bottomNavigationBar: AnimeBar(isBlocked: isLoading),
      body:
          _animeList == null || _recommendedList == null || mode == null
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                child: LayoutBuilder(
                  builder: (contex, constraints) {
                    final isWide = constraints.maxWidth > 600;
                    final horizontalPadding = isWide ? 64.0 : 16.0;
                    final verticalSpacing = isWide ? 24.0 : 16.0;
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
                      padding: EdgeInsets.symmetric(
                        horizontal: horizontalPadding,
                        vertical: 24,
                      ),
                      child: ListView(
                        children: [
                          SizedBox(
                            height: isWide ? 540 * 1.75 : 540,
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
                                    padding: EdgeInsets.symmetric(
                                      horizontal: horizontalPadding,
                                    ),
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
                                                fontSize:
                                                    isWide ? 30 * 1.75 : 30,
                                                fontFamily: 'Allan',
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            GestureDetector(
                                              onTap:
                                                  () => _showSettingsMenu(
                                                    context,
                                                    isWide,
                                                    screenWidth,
                                                    verticalSpacing,
                                                  ),
                                              child: Icon(
                                                Icons.person,
                                                size: isWide ? 30 * 1.75 : 30,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Text(
                                          l10n.app_name.toUpperCase(),
                                          style: TextStyle(
                                            fontSize: isWide ? 140 : 72,
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
                                fontSize: isWide ? 36 : 16,
                              ),
                            ),
                          ),
                          ReleasesCarousel(
                            releases: _animeList!,
                            isWide: isWide,
                          ),
                          SizedBox(height: 20),
                          Center(
                            child: Text(
                              l10n.recommended.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 3,
                                fontSize: isWide ? 36 : 16,
                              ),
                            ),
                          ),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: crossAxisCount,
                                  crossAxisSpacing: 16,
                                  mainAxisSpacing: 16,
                                  childAspectRatio: 2 / 3,
                                ),
                            itemCount: _recommendedList!.length,
                            itemBuilder: (context, index) {
                              return AnimeCard(
                                anime: _recommendedList![index],
                                isWide: isWide,
                              );
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }

  void _showSettingsMenu(
    BuildContext context,
    bool isWide,
    double screenWidth,
    double verticalSpacing,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final subtitleLanguages = [
      'en',
      'ru',
      'es',
      'fr',
      'de',
      'ja',
      'zh-cn',
      'ko',
      'it',
      'pt',
    ];

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        screenWidth - (isWide ? 120 : 80),
        kToolbarHeight + 20,
        16,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      color: Theme.of(context).colorScheme.surface,
      constraints: BoxConstraints(
        maxWidth: isWide ? screenWidth * 0.7 : screenWidth * 0.85,
        minWidth: isWide ? 400 : 280,
      ),
      items: [
        PopupMenuItem(
          enabled: false,
          padding: EdgeInsets.zero,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            child: StatefulBuilder(
              builder: (context, setStatePopup) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.anilibria,
                          style: TextStyle(
                            fontSize: isWide ? 48 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Switch(
                          value: mode == Mode.consumet,
                          onChanged: (value) async {
                            final newMode =
                                value ? Mode.consumet : Mode.anilibria;
                            await ModeStorage.saveMode(newMode);
                            setStatePopup(() {});
                            setState(() => mode = newMode);
                            Navigator.of(context).pushReplacement(
                              NoAnimationPageRoute(
                                builder: (_) => const AnimeListScreen(),
                              ),
                            );
                          },
                        ),
                        Text(
                          l10n.subtitle,
                          style: TextStyle(
                            fontSize: isWide ? 48 : 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: verticalSpacing * 0.8),

                    Text(
                      l10n.subtitle_translate_language,
                      style: TextStyle(
                        fontSize: isWide ? 30 : 15,
                        fontWeight: FontWeight.w500,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          subtitleLanguages.map((lang) {
                            final isSelected = translateLang == lang;
                            return ChoiceChip(
                              label: Text(
                                lang.toUpperCase(),
                                style: TextStyle(
                                  fontSize: isWide ? 28 : 13,
                                  fontWeight:
                                      isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: Theme.of(
                                context,
                              ).colorScheme.secondary.withOpacity(0.3),
                              backgroundColor: Colors.white10,
                              labelPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color:
                                      isSelected
                                          ? Theme.of(
                                            context,
                                          ).colorScheme.secondary
                                          : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              onSelected: (_) async {
                                await TranslateStorage().saveLanguage(lang);
                                setStatePopup(() {});
                                setState(() => translateLang = lang);
                              },
                            );
                          }).toList(),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
