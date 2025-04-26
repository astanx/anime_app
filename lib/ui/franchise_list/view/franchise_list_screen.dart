import 'package:anime_app/core/constants.dart';
import 'package:anime_app/data/models/franchise.dart';
import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/ui/franchise_list/widgets/widgets.dart';
import 'package:flutter/material.dart';

class FranchiseScreen extends StatelessWidget {
  const FranchiseScreen({super.key});

  Future<List<Anime>> _loadAnimeList(List<FranchiseRelease> releases) async {
    final repository = AnimeRepository();
    final List<Anime> animeList = [];
    
    for (final release in releases) {
        final anime = await repository.getAnimeById(release.releaseId);
        animeList.add(anime);
    }
    return animeList;
  }

  @override
  Widget build(BuildContext context) {
    final arguments =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final Franchise franchise = arguments['franchise'] as Franchise;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                franchise.name,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<List<Anime>>(
          future: _loadAnimeList(franchise.franchiseReleases),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error loading data: ${snapshot.error}'));
            }

            final animeList = snapshot.data ?? [];

            return ListView(
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
                          '$baseUrl${franchise.image.optimized.preview}',
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 24),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: animeList.length,
                          itemBuilder: (context, index) {
                            return FranchiseCard(
                              anime: animeList[index],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
