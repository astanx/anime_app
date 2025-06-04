import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  SearchInput({super.key});
  final _textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return TextField(
      controller: _textController,
      decoration: InputDecoration(
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: true,
        fillColor: const Color(0xFF1B1F26),
        hintText: l10n.anime_search_placeholder.toUpperCase(),
        hintStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          letterSpacing: 3,
        ),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            final query = _textController.text.trim();
            if (query.isNotEmpty) {
              Navigator.of(
                context,
              ).pushNamed('/genre/releases', arguments: {'query': query});
            }
          },
        ),
      ),
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) async {
        if (value.trim().isEmpty) return;

        final anime = await AnimeRepository().searchAnime(value);
        Navigator.of(
          context,
        ).pushNamed('/genre/releases', arguments: {'genreReleases': anime});
      },
    );
  }
}
