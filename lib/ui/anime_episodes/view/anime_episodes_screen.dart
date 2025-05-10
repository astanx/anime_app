import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/collection.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
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
    final favouritesProvider = Provider.of<FavouritesProvider>(context);
    final timecodeProvider = Provider.of<TimecodeProvider>(
      context,
      listen: false,
    );
    final isFavourite = favouritesProvider.isFavourite(anime.release.id);
    final collection = Provider.of<CollectionsProvider>(
      context,
      listen: false,
    ).getCollectionType(anime);

    return Scaffold(
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
              icon: Icon(isFavourite ? Icons.star : Icons.star_outline),
              color: isFavourite ? theme.colorScheme.secondary : null,
              tooltip: 'Favourite',
              onPressed: () {
                favouritesProvider.toggleFavourite(anime);
              },
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        '$baseUrl${anime.release.poster.optimized.src}',
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children:
                          anime.release.genres
                              .map(
                                (g) => Chip(
                                  label: Text(g.name),
                                  backgroundColor: theme.colorScheme.surface,
                                  labelStyle: theme.textTheme.labelSmall,
                                ),
                              )
                              .toList(),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      spacing: 30.0,
                      children: [
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
                                final franchise = await AnimeRepository()
                                    .getFranchiseById(anime.release.id);
                                Navigator.of(context).pushNamed(
                                  '/anime/franchise',
                                  arguments: {'franchise': franchise},
                                );
                              },
                              child: Icon(Icons.movie_filter_rounded, size: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Franchise',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 8),
                        Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.secondary,
                                foregroundColor: theme.colorScheme.onSecondary,
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
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Could not launch URL',
                                      ),
                                      backgroundColor: theme.colorScheme.error,
                                    ),
                                  );
                                }
                              },
                              child: Icon(Icons.download_rounded, size: 28),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Torrent',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
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
                                final provider =
                                    Provider.of<CollectionsProvider>(
                                      context,
                                      listen: false,
                                    );
                                final currentType = provider.getCollectionType(
                                  anime,
                                );

                                await showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(16.0),
                                          child: Text(
                                            'Select a collection',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        ...CollectionType.values.map((type) {
                                          return ListTile(
                                            leading: Icon(switch (type) {
                                              CollectionType.watched =>
                                                Icons.check,
                                              CollectionType.abandoned =>
                                                Icons.close,
                                              CollectionType.postponed =>
                                                Icons.pause,
                                              CollectionType.planned =>
                                                Icons.calendar_month,
                                              CollectionType.watching =>
                                                Icons.play_arrow,
                                            }),
                                            title: Text(
                                              type.name.toUpperCase(),
                                            ),
                                            selected: currentType == type,
                                            onTap: () async {
                                              if (currentType != type) {
                                                await provider.addToCollection(
                                                  type,
                                                  anime,
                                                );
                                              }

                                              Navigator.of(context).pop();
                                            },
                                          );
                                        }),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: switch (collection) {
                                CollectionType.watched => Icon(
                                  Icons.check,
                                  size: 28,
                                ),

                                CollectionType.abandoned => Icon(
                                  Icons.close,
                                  size: 28,
                                ),
                                CollectionType.postponed => Icon(
                                  Icons.pause,
                                  size: 28,
                                ),
                                CollectionType.planned => Icon(
                                  Icons.calendar_month,
                                  size: 28,
                                ),

                                CollectionType.watching => Icon(
                                  Icons.play_arrow,
                                  size: 28,
                                ),
                                null => Icon(Icons.folder_open, size: 28),
                              },
                            ),
                            const SizedBox(height: 4),
                            Text(
                              collection?.name.toUpperCase() ?? 'Collection',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Episodes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: GridView.builder(
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
