import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/ui/anime_episodes/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class AnimeEpisodesScreen extends StatelessWidget {
  const AnimeEpisodesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Anime anime = arguments['anime'] as Anime;
    final theme = Theme.of(context);

    double screenWidth = MediaQuery.of(context).size.width;
    int crossAxisCount = 2;
    if (screenWidth >= 600) crossAxisCount = 3;
    if (screenWidth >= 900) crossAxisCount = 4;

    final timecodeProvider = Provider.of<TimecodeProvider>(
      context,
      listen: false,
    );
    return Scaffold(
      appBar: AppBar(title: Text(anime.release.names.main)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: theme.cardTheme.color,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.network(
                      '$baseUrl${anime.release.poster.optimized.src}',
                      fit: BoxFit.cover,
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
                    Text(
                      anime.release.genres.map((g) => g.name).join(' • '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${anime.release.episodesTotal} episodes ${anime.release.isOngoing ? '| Ongoing' : ''}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () async {
                        final uri = Uri.parse(
                          '$baseUrl/api/v1/anime/torrents/${anime.torrents.first.id}/file',
                        );
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not launch URL'),
                            ),
                          );
                        }
                      },
                      child: const Text('Download via Torrent'),
                    ),
                    const SizedBox(height: 24),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: anime.episodes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 3 / 1,
                      ),
                      itemBuilder: (context, index) {
                        return EpisodeCard(
                          anime: anime,
                          episodeIndex: index,
                          timecodeProvider: timecodeProvider,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
