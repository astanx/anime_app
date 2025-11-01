import 'package:anime_app/data/models/mode.dart';
import 'package:anime_app/data/repositories/anime_repository.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/search/widgets/widgets.dart';
import 'package:flutter/material.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late AnimeRepository repository;
  final _textController = TextEditingController();
  Mode? mode;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final m = await ModeStorage.getMode();

      setState(() {
        mode = m;
        repository = AnimeRepository(mode: m);
      });
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body: LayoutBuilder(
        builder: (contex, constraints) {
          final isWide = constraints.maxWidth > 600;
          return SizedBox(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset('assets/images/search_page.png', fit: BoxFit.cover),
                Padding(
                  padding: EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SearchInput(
                        controller: _textController,
                        isWide: isWide,
                        onSubmitted: (value) {
                          final query = value.trim();
                          if (query.isNotEmpty) {
                            Navigator.of(context).pushNamed(
                              '/anime/releases',
                              arguments: {'query': query},
                            );
                          }
                        },
                        onPressed: () {
                          final query = _textController.text.trim();
                          if (query.isNotEmpty) {
                            Navigator.of(context).pushNamed(
                              '/anime/releases',
                              arguments: {'query': query},
                            );
                          }
                        },
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: 0.6,
                          child: Center(
                            child: Text(
                              l10n.search_anime.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Allan',
                                fontSize: isWide ? 90 : 48,
                              ),
                              maxLines: 2,
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
          );
        },
      ),
    );
  }
}
