import 'package:anime_app/core/constants.dart';
import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/models/history.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/history_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/l10n/collection_localization.dart';
import 'package:anime_app/ui/anime_episodes/widgets/widgets.dart';
import 'package:anime_app/ui/core/ui/anime_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class AnimeEpisodesScreen extends StatefulWidget {
  const AnimeEpisodesScreen({super.key});

  @override
  State<AnimeEpisodesScreen> createState() => _AnimeEpisodesScreenState();
}

class _AnimeEpisodesScreenState extends State<AnimeEpisodesScreen> {
  bool _showKodikPlayer = false;
  String? _kodikPlayerUrl;
  final repository = AnimeRepository();
  late WebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _webViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onNavigationRequest: (request) => NavigationDecision.navigate,
              onWebResourceError: (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('WebView error: ${error.description}'),
                    backgroundColor: Theme.of(context).colorScheme.error,
                  ),
                );
              },
            ),
          );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final Anime anime = arguments['anime'] as Anime;
      final KodikResult? kodikResult = arguments['kodikResult'] as KodikResult?;
      final bool? showKodik = arguments['showKodik'] as bool?;

      if ((anime.release.id == -1 && kodikResult != null) ||
          ((showKodik ?? false) && kodikResult != null)) {
        setState(() {
          _showKodikPlayer = true;
          _kodikPlayerUrl = 'https:${kodikResult.link}';
          _webViewController.loadHtmlString(getIframeHtml(_kodikPlayerUrl!));
        });
      }
    });
  }

  String getIframeHtml(String url) {
    return '''
  <html>
    <head>
      <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
      <style>
        html, body {
          margin: 0;
          padding: 0;
          width: 100%;
          height: 100%;
          overflow: hidden;
        }
        iframe {
          position: absolute;
          top: 0;
          left: 0;
          width: 100%;
          height: 100%;
          border: none;
        }
      </style>
    </head>
    <body>
      <iframe src="$url" allowfullscreen></iframe>
    </body>
  </html>
  ''';
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Anime anime = arguments['anime'] as Anime;
    final KodikResult? kodikResult = arguments['kodikResult'] as KodikResult?;
    final theme = Theme.of(context);

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth >= 600) crossAxisCount = 3;
    if (screenWidth >= 900) crossAxisCount = 4;

    final favouritesProvider = Provider.of<FavouritesProvider>(context);
    final timecodeProvider = Provider.of<TimecodeProvider>(
      context,
      listen: false,
    );
    final collectionProvider = Provider.of<CollectionsProvider>(
      context,
      listen: false,
    );
    final l10n = AppLocalizations.of(context);
    final isFavourite = favouritesProvider.isFavourite(anime);

    final collection = collectionProvider.getCollectionType(anime);

    return ChangeNotifierProvider(
      create: (context) {
        final provider = VideoControllerProvider();
        if (!_showKodikPlayer && anime.release.episodesTotal == 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await provider.loadEpisode(anime, 0, context, kodikResult);
          });
        }
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  anime.release.names.main,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: Icon(isFavourite ? Icons.star : Icons.star_outline),
                color: isFavourite ? theme.colorScheme.secondary : null,
                onPressed: () => favouritesProvider.toggleFavourite(anime),
              ),
              if (kodikResult != null && anime.episodes.isNotEmpty)
                IconButton(
                  icon: Icon(
                    _showKodikPlayer ? Icons.movie : Icons.play_circle_fill,
                  ),
                  onPressed: () {
                    setState(() {
                      _showKodikPlayer = !_showKodikPlayer;
                      if (_showKodikPlayer) {
                        _kodikPlayerUrl = 'https:${kodikResult.link}';
                        _webViewController.loadHtmlString(
                          getIframeHtml(_kodikPlayerUrl!),
                        );
                      } else {
                        Provider.of<VideoControllerProvider>(
                          context,
                          listen: false,
                        ).loadEpisode(anime, 0, context, kodikResult);
                      }
                    });
                  },
                ),
              if (kodikResult != null && anime.episodes.isEmpty)
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    final history = History(
                      animeId: -1,
                      lastWatchedEpisode: 0,
                      isWatched: true,
                      kodikResult: kodikResult,
                    );
                    HistoryStorage.updateHistory(history);
                  },
                ),
              IconButton(
                icon: const Icon(Icons.home),
                onPressed: () => Navigator.of(context).pushNamed('/anime/list'),
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: ListView(
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
                          getImageUrl(anime),
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        anime.release.names.main,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      if (anime.release.id != -1)
                        Wrap(
                          spacing: 8,
                          children:
                              anime.release.genres
                                  .map(
                                    (g) => Chip(
                                      label: Text(g.name),
                                      backgroundColor:
                                          theme.colorScheme.surface,
                                      labelStyle: theme.textTheme.labelSmall,
                                    ),
                                  )
                                  .toList(),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        anime.release.episodesTotal > 0
                            ? '${l10n!.episode_count(anime.release.episodesTotal)} ${anime.release.isOngoing ? '| ${l10n.ongoing}' : ''}'
                            : kodikResult?.type == 'anime'
                            ? l10n!.movie
                            : l10n!.series,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: anime.release.id != -1 ? 30.0 : 0.0,
                        children: [
                          if (anime.release.id != -1)
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(16),
                                  ),
                                  onPressed: () async {
                                    final franchise = await AnimeRepository()
                                        .getFranchiseById(anime.release.id);
                                    Navigator.pushNamed(
                                      context,
                                      '/anime/franchise',
                                      arguments: {'franchise': franchise},
                                    );
                                  },
                                  child: const Icon(
                                    Icons.movie_filter_rounded,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.franchise,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          const SizedBox(width: 8),
                          if (anime.release.id != -1)
                            Column(
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        theme.colorScheme.secondary,
                                    foregroundColor:
                                        theme.colorScheme.onSecondary,
                                    shape: const CircleBorder(),
                                    padding: const EdgeInsets.all(16),
                                  ),
                                  onPressed: () async {
                                    final uri = Uri.parse(
                                      '$baseUrl/api/v1/anime/torrents/${anime.torrents.first.id}/file',
                                    );
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(l10n.url_error),
                                          backgroundColor:
                                              theme.colorScheme.error,
                                        ),
                                      );
                                    }
                                  },
                                  child: const Icon(
                                    Icons.download_rounded,
                                    size: 28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.torrent,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ],
                            ),
                          const SizedBox(width: 8),
                          Column(
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: theme.colorScheme.primary,
                                  foregroundColor: theme.colorScheme.onPrimary,
                                  shape: const CircleBorder(),
                                  padding: const EdgeInsets.all(16),
                                ),
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
                                                      leading: Icon(
                                                        switch (type) {
                                                          CollectionType
                                                              .watched =>
                                                            Icons.check,
                                                          CollectionType
                                                              .abandoned =>
                                                            Icons.close,
                                                          CollectionType
                                                              .postponed =>
                                                            Icons.pause,
                                                          CollectionType
                                                              .planned =>
                                                            Icons
                                                                .calendar_month,
                                                          CollectionType
                                                              .watching =>
                                                            Icons.play_arrow,
                                                        },
                                                      ),
                                                      title: Text(
                                                        type.localizedName(
                                                          context,
                                                        ),
                                                      ),
                                                      selected:
                                                          collection == type,
                                                      onTap: () async {
                                                        if (collection !=
                                                            type) {
                                                          await collectionProvider
                                                              .addToCollection(
                                                                type,
                                                                anime,
                                                                kodikResult,
                                                              );
                                                        }
                                                        Navigator.pop(context);
                                                      },
                                                    ),
                                                  )
                                                  .toList(),
                                        ),
                                  );
                                },
                                child: switch (collection) {
                                  CollectionType.watched => const Icon(
                                    Icons.check,
                                    size: 28,
                                  ),
                                  CollectionType.abandoned => const Icon(
                                    Icons.close,
                                    size: 28,
                                  ),
                                  CollectionType.postponed => const Icon(
                                    Icons.pause,
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
                                  null => const Icon(
                                    Icons.folder_open,
                                    size: 28,
                                  ),
                                },
                              ),
                              const SizedBox(height: 4),
                              Text(
                                collection?.localizedName(context) ??
                                    l10n.collection,
                                style: theme.textTheme.labelSmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      if (anime.release.description != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            anime.release.description!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12,
                            ),
                          ),
                        ),
                      if (_showKodikPlayer && _kodikPlayerUrl != null)
                        Column(
                          children: [
                            Text(
                              l10n.kodik_player,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: 300,
                              child: WebViewWidget(
                                controller: _webViewController,
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      if (!_showKodikPlayer && anime.release.episodesTotal == 0)
                        AnimePlayer(anime: anime, kodikResult: kodikResult)
                      else if (anime.release.episodesTotal > 0 &&
                          anime.release.id != -1)
                        Column(
                          children: [
                            Text(
                              l10n.episode(1),
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 16),
                            if (anime.release.id != -1)
                              GridView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: anime.episodes.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: crossAxisCount,
                                      crossAxisSpacing: 16,
                                      mainAxisSpacing: 16,
                                      childAspectRatio: 3 / 1,
                                    ),
                                itemBuilder:
                                    (context, index) => EpisodeCard(
                                      anime: anime,
                                      episodeIndex: index,
                                      timecodeProvider: timecodeProvider,
                                      kodikResult: kodikResult,
                                    ),
                              )
                            else
                              const Center(child: CircularProgressIndicator()),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
