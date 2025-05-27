import 'package:anime_app/data/provider/favourites_provider.dart';
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

  @override
  void initState() {
    final provider = Provider.of<FavouritesProvider>(context, listen: false);
    provider.fetchFavourites();

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
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Consumer<FavouritesProvider>(
            builder: (context, provider, _) {
              final favourites = provider.favourites;

              if (favourites.isEmpty && !provider.isLoadingMore) {
                return const Center(child: Text('No favourites found.'));
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
                        } else {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
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
