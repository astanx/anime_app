import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/data/storage/anime_mode_storage.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return ChangeNotifierProvider(
      create: (context) {
        final provider = VideoControllerProvider(mode: mode);
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await provider.loadEpisode(anime, episodeIndex, context);
        });
        return provider;
      },
      child: Consumer<VideoControllerProvider>(
        builder: (context, provider, _) {
          final screenWidth = MediaQuery.of(context).size.width;
          final isWide = screenWidth >= 600;
          return Scaffold(
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      anime.title,
                      overflow: TextOverflow.ellipsis,
                      softWrap: false,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: isWide ? 32 : 18,
                      ),
                    ),
                  ),
                  if (anime.previewEpisodes[episodeIndex].isDubbed &&
                      anime.previewEpisodes[episodeIndex].isSubbed) ...[
                    PopupMenuButton<int>(
                      tooltip:
                          provider.isDubbedMode
                              ? 'Switch to Sub'
                              : 'Switch to Dub',
                      offset: const Offset(0, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      initialValue: provider.isDubbedMode ? 1 : 0,
                      onSelected: (value) {
                        if (value == 0 && provider.isDubbedMode) {
                          provider.toggleDubbed();
                          provider.loadEpisode(anime, episodeIndex, context);
                        } else if (value == 1 && !provider.isDubbedMode) {
                          provider.toggleDubbed();
                          provider.loadEpisode(anime, episodeIndex, context);
                        }
                        if (!provider.sawDubSubTutorial) {
                          AnimeModeStorage.setSawDubSubTutorial(true);
                          provider.changeSubDubTutorial(true);
                        }
                      },
                      itemBuilder:
                          (context) => [
                            if (!provider.sawDubSubTutorial)
                              PopupMenuItem<int>(
                                value: -1,
                                enabled: false,
                                child: ListTile(
                                  leading: Icon(
                                    Icons.info_outline,
                                    color: Colors.blue,
                                  ),
                                  title: Text(
                                    l10n.new_sub_dub,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(l10n.episode_supports_both),
                                ),
                              ),
                            PopupMenuItem<int>(
                              value: 0,
                              child: ListTile(
                                leading: Icon(Icons.subtitles),
                                title: Text(l10n.subbed),
                              ),
                            ),
                            PopupMenuItem<int>(
                              value: 1,
                              child: ListTile(
                                leading: Icon(Icons.record_voice_over),
                                title: Text(l10n.dubbed),
                              ),
                            ),
                          ],
                      child: Stack(
                        children: [
                          Icon(
                            provider.isDubbedMode
                                ? Icons.record_voice_over
                                : Icons.subtitles,
                            size: isWide ? 38 : 24,
                          ),
                          if (!provider.sawDubSubTutorial)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                  if (isWide) SizedBox(width: 30),
                  IconButton(
                    icon: const Icon(Icons.home),
                    tooltip: 'Home',
                    iconSize: isWide ? 38 : 24,
                    onPressed: () {
                      Navigator.of(context).pushNamed('/anime/list');
                    },
                  ),
                ],
              ),
            ),
            body: SafeArea(
              child: LayoutBuilder(
                builder: (contex, constraints) {
                  final isWide = constraints.maxWidth > 600;
                  return _buildBody(context, provider, anime, theme, isWide);
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    VideoControllerProvider provider,
    Anime anime,
    ThemeData theme,
    bool isWide,
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
                        fontSize: isWide ? 36 : 18,
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
                            fontSize: isWide ? 18 : 12,
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
                      style: TextStyle(
                        fontSize: isWide ? 26 : 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimePlayer(anime: anime, isWide: isWide),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (episodeIndex > 0)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  provider.loadEpisode(
                                    anime,
                                    episodeIndex - 1,
                                    context,
                                  );
                                },
                                icon: Icon(
                                  Icons.skip_previous,
                                  size: isWide ? 40 : 20,
                                ),
                                label: Text(
                                  anime
                                              .previewEpisodes[episodeIndex - 1]
                                              .title !=
                                          ''
                                      ? anime
                                          .previewEpisodes[episodeIndex - 1]
                                          .title
                                      : l10n.prev_episode,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: isWide ? 28 : 14),
                                ),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isWide ? 20 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onSecondaryContainer,
                                  elevation: 2,
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),
                        if (episodeIndex < anime.previewEpisodes.length - 1)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: ElevatedButton(
                                onPressed: () async {
                                  provider.loadEpisode(
                                    anime,
                                    episodeIndex + 1,
                                    context,
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: isWide ? 20 : 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  backgroundColor:
                                      theme.colorScheme.secondaryContainer,
                                  foregroundColor:
                                      theme.colorScheme.onSecondaryContainer,
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        anime
                                                .previewEpisodes[episodeIndex +
                                                    1]
                                                .title
                                                .isNotEmpty
                                            ? anime
                                                .previewEpisodes[episodeIndex +
                                                    1]
                                                .title
                                            : l10n.next_episode,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: isWide ? 28 : 14,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Icon(
                                      Icons.skip_next,
                                      size: isWide ? 40 : 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          const Spacer(),
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
