import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/search/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final repository = AnimeRepository();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/search_page.png', fit: BoxFit.cover),
            Padding(
              padding: EdgeInsets.all(25.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SearchInput(),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.6,
                      child: Center(
                        child: AutoSizeText(
                          l10n.search_anime.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          minFontSize: 48,
                          maxFontSize: 64,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
