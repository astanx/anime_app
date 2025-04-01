import 'package:anime_app/data/models/anime.dart';
import 'package:flutter/material.dart';

class AnimeTile extends StatelessWidget {
  const AnimeTile({super.key, required this.anime});

  final Anime anime;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Image.network(
        'https://anilibria.top${anime.poster.optimized.src}',
      ),
      title: Text(anime.names.main, style: theme.textTheme.bodyMedium),
      subtitle: Text(anime.description, style: theme.textTheme.labelSmall),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: () {
        Navigator.of(context).pushNamed('/anime', arguments: anime);
      },
    );
  }
}
