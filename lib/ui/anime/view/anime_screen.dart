import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/anime_player/anime_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AnimeScreen extends StatelessWidget {
  const AnimeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Anime anime = arguments['anime'] as Anime;
    final int episodeIndex = arguments['episodeIndex'] as int;
    final Mode mode = arguments['mode'];
    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (context) {
        final provider = VideoControllerProvider(mode: mode);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await provider.loadEpisode(anime, episodeIndex, context);
        });
        return provider;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  anime.title,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.home),
                tooltip: 'Home',
                onPressed: () {
                  Navigator.of(context).pushNamed('/anime/list');
                },
              ),
            ],
          ),
        ),
        body: SafeArea(
          child: Consumer<VideoControllerProvider>(
            builder: (context, provider, _) {
              return _buildBody(context, provider, anime, theme);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VideoControllerProvider provider,
    Anime anime,
    ThemeData theme,
  ) {
    final episodeIndex = provider.episodeIndex;
    final l10n = AppLocalizations.of(context);
    return episodeIndex == null
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: theme.cardTheme.color,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Image.network(anime.poster, fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    Text(
                      anime.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (anime.description != '') ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          anime.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      anime.previewEpisodes[episodeIndex].title != ''
                          ? '${l10n!.episode(0)} ${anime.previewEpisodes[episodeIndex].ordinal}: ${anime.previewEpisodes[episodeIndex].title}'
                          : '${l10n!.episode(0)} ${anime.previewEpisodes[episodeIndex].ordinal}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimePlayer(anime: anime),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (episodeIndex > 0)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: InkWell(
                              onTap: () async {
                                provider.loadEpisode(
                                  anime,
                                  episodeIndex - 1,
                                  context,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Icon(Icons.skip_previous),
                                    Flexible(
                                      child: Text(
                                        anime
                                                    .previewEpisodes[episodeIndex -
                                                        1]
                                                    .title !=
                                                ''
                                            ? anime
                                                .previewEpisodes[episodeIndex -
                                                    1]
                                                .title
                                            : l10n.prev_episode,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 150, height: 50),
                        if (episodeIndex < anime.previewEpisodes.length - 1)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: InkWell(
                              onTap: () async {
                                provider.loadEpisode(
                                  anime,
                                  episodeIndex + 1,
                                  context,
                                );
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.grey,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        anime
                                                    .previewEpisodes[episodeIndex +
                                                        1]
                                                    .title !=
                                                ''
                                            ? anime
                                                .previewEpisodes[episodeIndex +
                                                    1]
                                                .title
                                            : l10n.next_episode,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ),
                                    const Icon(Icons.skip_next),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const SizedBox(width: 150, height: 50),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
  }
}
