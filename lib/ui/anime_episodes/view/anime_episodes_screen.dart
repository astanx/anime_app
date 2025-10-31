import 'dart:math' as math;
import 'package:anime_app/core/utils/is_ongoing.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/favourite.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/l10n/collection_localization.dart';
import 'package:anime_app/ui/anime_episodes/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/anime_player/view/anime_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimeEpisodesScreen extends StatefulWidget {
  const AnimeEpisodesScreen({super.key});

  @override
  State<AnimeEpisodesScreen> createState() => _AnimeEpisodesScreenState();
}

class _AnimeEpisodesScreenState extends State<AnimeEpisodesScreen> {
  late AnimeRepository repository;
  late Anime anime;
  CollectionType? collection;
  Favourite? favourite;
  Mode? mode;
  TimecodeProvider? _timecodeProvider;
  late ScrollController _scrollController;
  int _visibleEpisodes = 30;
  bool _isLoading = true;
  bool _isFetched = false;

  bool get hasMore => _visibleEpisodes < anime.previewEpisodes.length;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_loadMore);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final animeID = arguments['animeID'];
    final timecodeProvider = Provider.of<TimecodeProvider>(
      context,
      listen: false,
    );
    final collectionProvider = Provider.of<CollectionsProvider>(
      context,
      listen: false,
    );
    final favouritesProvider = Provider.of<FavouritesProvider>(
      context,
      listen: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final m = await ModeStorage.getMode();
      repository = AnimeRepository(mode: m);

      if (arguments['anime'] == null) {
        if (_isFetched) return;
        anime = await repository.getAnimeById(animeID);
      } else {
        anime = arguments['anime'];
      }
      if (!_isFetched) {
        collection = await collectionProvider.fetchCollectionForAnime(anime);
        favourite = await favouritesProvider.fetchFavouriteForAnime(anime);
      }

      await timecodeProvider.fetchTimecodesForAnime(anime.id);
      setState(() {
        mode = m;
        _timecodeProvider = timecodeProvider;
        _isLoading = false;
        _isFetched = true;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMore() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _visibleEpisodes += 30;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth >= 600) crossAxisCount = 3;
    if (screenWidth >= 900) crossAxisCount = 4;
    final favouritesProvider = Provider.of<FavouritesProvider>(context);
    final collectionProvider = Provider.of<CollectionsProvider>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context)!;
    if (mode == null || _timecodeProvider == null || _isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    var isFavourite = favourite != null;

    return ChangeNotifierProvider(
      create: (context) {
        final provider = VideoControllerProvider(mode: mode!);
        if (anime.isMovie) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await provider.loadEpisode(anime, 0, context);
          });
        }
        return provider;
      },
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      anime.title,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    icon: Icon(isFavourite ? Icons.star : Icons.star_outline),
                    color: isFavourite ? theme.colorScheme.secondary : null,
                    onPressed: () async {
                      isFavourite = await favouritesProvider.toggleFavourite(
                        anime,
                      );
                      setState(() {
                        favourite =
                            isFavourite ? Favourite(animeID: anime.id) : null;
                      });
                    },
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      await showModalBottomSheet(
                        context: context,
                        builder:
                            (context) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children:
                                  CollectionType.values
                                      .map(
                                        (type) => ListTile(
                                          leading: Icon(switch (type) {
                                            CollectionType.watched =>
                                              Icons.check,
                                            CollectionType.abandoned =>
                                              Icons.close,
                                            CollectionType.planned =>
                                              Icons.calendar_month,
                                            CollectionType.watching =>
                                              Icons.play_arrow,
                                          }),
                                          title: Text(
                                            type.localizedName(context),
                                          ),
                                          selected: collection == type,
                                          onTap: () async {
                                            if (collection != type) {
                                              await collectionProvider
                                                  .addToCollection(type, anime);
                                              setState(() {
                                                collection = type;
                                              });
                                            } else {
                                              await collectionProvider
                                                  .removeFromCollection(
                                                    type,
                                                    anime,
                                                  );
                                              setState(() {
                                                collection = null;
                                              });
                                            }
                                            Navigator.pop(context);
                                          },
                                        ),
                                      )
                                      .toList(),
                            ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                    ),
                    child: switch (collection) {
                      CollectionType.watched => const Icon(
                        Icons.check,
                        size: 28,
                      ),
                      CollectionType.abandoned => const Icon(
                        Icons.close,
                        size: 28,
                      ),
                      CollectionType.planned => const Icon(
                        Icons.calendar_month,
                        size: 28,
                      ),
                      CollectionType.watching => const Icon(
                        Icons.play_arrow,
                        size: 28,
                      ),
                      null => const Icon(Icons.folder_open, size: 28),
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.home),
                    onPressed:
                        () => Navigator.of(context).pushNamed('/anime/list'),
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: theme.cardTheme.color,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              anime.poster,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            anime.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children:
                                anime.genres
                                    .map(
                                      (g) => Chip(
                                        label: Text(g),
                                        backgroundColor:
                                            theme.colorScheme.surface,
                                        labelStyle: theme.textTheme.labelSmall,
                                      ),
                                    )
                                    .toList(),
                          ),
                          const SizedBox(height: 4),
                          if (anime.totalEpisodes > 0 && !anime.isMovie)
                            Text(
                              '${l10n.episode_count(anime.totalEpisodes)} ${isOngoing(anime) ? '| ${l10n.ongoing}' : ''}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          Text(
                            anime.type,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),
                          if (anime.description != '')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                anime.description,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          if (!anime.isMovie)
                            Column(
                              children: [
                                Text(
                                  l10n.episode(1),
                                  style: theme.textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: math.min(
                                    _visibleEpisodes,
                                    anime.previewEpisodes.length,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: crossAxisCount,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 3 / 1,
                                      ),
                                  itemBuilder: (context, index) {
                                    return EpisodeCard(
                                      anime: anime,
                                      episodeIndex: index,
                                      timecodeProvider: _timecodeProvider!,
                                      mode: mode!,
                                    );
                                  },
                                ),
                              ],
                            )
                          else
                            AnimePlayer(anime: anime),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
