import 'package:anime_app/data/models/anime.dart';
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
  List<Anime>? _favouritesList;

  @override
  void initState() {
    _favouritesList =
        Provider.of<FavouritesProvider>(context, listen: false).favourites;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              _favouritesList == null
                  ? const Center(child: CircularProgressIndicator())
                  : _favouritesList!.isEmpty
                  ? const Center(child: Text('No favourites found.'))
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: _favouritesList!.length,
                          itemBuilder: (context, index) {
                            return FavouritesCard(
                              anime: _favouritesList![index],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
