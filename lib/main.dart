import 'package:anime_app/anime_app.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/provider/history_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimecodeProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider()),
        ChangeNotifierProvider(create: (_) => CollectionsProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
      ],
      child: const AnimeApp(),
    ),
  );
}
