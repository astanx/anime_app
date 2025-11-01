import 'package:anime_app/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class SearchInput extends StatelessWidget {
  const SearchInput({
    super.key,
    required this.isWide,
    required this.onPressed,
    required this.onSubmitted,
    required this.controller,
  });
  final TextEditingController controller;
  final VoidCallback onPressed;
  final ValueChanged onSubmitted;
  final bool isWide;
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    double screenWidth = MediaQuery.of(context).size.width;

    return Center(
      child: SizedBox(
        width: screenWidth,
        height: MediaQuery.of(context).size.height * 0.1,
        child: TextField(
          controller: controller,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: isWide ? 20 : 12,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: true,
            fillColor: const Color(0xFF1B1F26),
            hintText: l10n.anime_search_placeholder.toUpperCase(),
            hintStyle: TextStyle(
              color: Colors.white,
              fontSize: isWide ? 36 : 18,
            ),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.search,
                color: Colors.white,
                size: isWide ? 36 : 18,
              ),
              onPressed: onPressed,
            ),
          ),
          style: TextStyle(color: Colors.white, fontSize: isWide ? 36 : 18),
          textInputAction: TextInputAction.search,
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
