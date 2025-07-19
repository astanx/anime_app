import 'package:anime_app/core/utils/url_utils.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/kodik_result.dart';
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
    final KodikResult? kodikResult = arguments['kodikResult'] as KodikResult?;
    final int episodeIndex = arguments['episodeIndex'] as int;

    final theme = Theme.of(context);

    return ChangeNotifierProvider(
      create: (context) {
        final provider = VideoControllerProvider();
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await provider.loadEpisode(anime, episodeIndex, context, kodikResult);
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
                  anime.release.names.main,
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
              return _buildBody(context, provider, anime, theme, kodikResult);
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
    KodikResult? kodikResult,
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
                    Image.network(getImageUrl(anime), fit: BoxFit.cover),
                    const SizedBox(height: 8),
                    Text(
                      anime.release.names.main,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (anime.release.description != null) ...[
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          anime.release.description!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Text(
                      anime.episodes[episodeIndex].name != null ||
                              anime.episodes[episodeIndex].nameEnglish != null
                          ? '${l10n!.episode(0)} ${anime.episodes[episodeIndex].ordinalFormatted}: ${anime.episodes[episodeIndex].name ?? anime.episodes[episodeIndex].nameEnglish}'
                          : '${l10n!.episode(0)} ${anime.episodes[episodeIndex].ordinalFormatted}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimePlayer(anime: anime, kodikResult: kodikResult),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (episodeIndex > 0)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: InkWell(
                              onTap:
                                  () => {
                                    provider.loadEpisode(
                                      anime,
                                      episodeIndex - 1,
                                      context,
                                      kodikResult,
                                    ),
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
                                        anime.episodes[episodeIndex - 1].name ??
                                            l10n.prev_episode,
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
                        if (episodeIndex < anime.episodes.length - 1)
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: InkWell(
                              onTap:
                                  () => {
                                    provider.loadEpisode(
                                      anime,
                                      episodeIndex + 1,
                                      context,
                                      kodikResult,
                                    ),
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
                                        anime.episodes[episodeIndex + 1].name ??
                                            l10n.next_episode,
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
