import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:anime_app/l10n/app_localizations.dart';
import 'package:anime_app/ui/core/ui/app_bar.dart';
import 'package:anime_app/ui/favourites/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  @override
  void initState() {
    final provider = Provider.of<FavouritesProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await provider.fetchFavourites();
      setState(() {
        _isLoading = false;
      });
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 300) {
        provider.fetchNextPage();
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      bottomNavigationBar: AnimeBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<FavouritesProvider>(
            builder: (context, provider, _) {
              final favourites = provider.favourites;
              if (_isLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (favourites.isEmpty && !provider.isLoadingMore) {
                return Center(child: Text(l10n.no_favourites_found));
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: favourites.length + (provider.hasMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < favourites.length) {
                          return FavouritesCard(anime: favourites[index]);
                        } else if (_isLoading || provider.isLoadingMore) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
