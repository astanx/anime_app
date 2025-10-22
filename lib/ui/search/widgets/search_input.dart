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
        hintStyle: const TextStyle(color: Colors.white, fontSize: 18),
        suffixIcon: IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {
            final query = _textController.text.trim();
            if (query.isNotEmpty) {
              Navigator.of(
                context,
              ).pushNamed('/anime/releases', arguments: {'query': query});
            }
          },
        ),
      ),
      style: const TextStyle(color: Colors.white),
      textInputAction: TextInputAction.search,
      onSubmitted: (value) async {
        if (value.trim().isEmpty) return;

        final query = value.trim();
        if (query.isNotEmpty) {
          Navigator.of(
            context,
          ).pushNamed('/anime/releases', arguments: {'query': query});
        }
      },
    );
  }
}
