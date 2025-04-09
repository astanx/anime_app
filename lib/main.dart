import 'package:anime_app/anime_app.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => VideoControllerProvider(),
      child: const AnimeApp(),
    ),
  );
}
