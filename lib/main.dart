import 'package:anime_app/anime_app.dart';
import 'package:anime_app/data/provider/timecode_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => TimecodeProvider(),
      child: const AnimeApp(),
    ),
  );
}
