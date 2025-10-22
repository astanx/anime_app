import 'package:anime_app/anime_app.dart';
import 'package:anime_app/data/provider/collections_provider.dart';
import 'package:anime_app/data/provider/history_provider.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:anime_app/data/provider/favourites_provider.dart';
import 'package:anime_app/data/storage/mode_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final mode = await ModeStorage.getMode();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TimecodeProvider()),
        ChangeNotifierProvider(create: (_) => FavouritesProvider(mode: mode)),
        ChangeNotifierProvider(create: (_) => CollectionsProvider(mode: mode)),
        ChangeNotifierProvider(create: (_) => HistoryProvider(mode: mode)),
      ],
      child: const AnimeApp(),
    ),
  );
}
