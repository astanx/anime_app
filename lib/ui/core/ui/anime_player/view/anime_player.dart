import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/models/kodik_result.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/ui/core/ui/anime_player/widgets/fullscreen_player.dart';
import 'package:anime_app/ui/core/ui/anime_player/widgets/player_controls.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

class AnimePlayer extends StatelessWidget {
  final Anime anime;
  final KodikResult? kodikResult;

  const AnimePlayer({
    super.key,
    required this.anime,
    required this.kodikResult,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerProvider>(
      builder: (context, provider, _) {
        final controller = provider.controller;
        final position = controller?.value.position ?? Duration.zero;

        if (!(controller?.value.isInitialized ?? false)) {
          return const Center(child: CircularProgressIndicator());
        }

        return AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: controller.value.aspectRatio,
                child: VideoPlayer(controller),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.replay_10,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => provider.seek(
                                  position - const Duration(seconds: 10),
                                ),
                          ),
                          IconButton(
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: provider.togglePlayPause,
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => provider.seek(
                                  position + const Duration(seconds: 10),
                                ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => FullscreenPlayer(
                                          provider: provider,
                                          anime: anime,
                                          kodikResult: kodikResult,
                                        ),
                                  ),
                                ),
                          ),
                        ],
                      ),
                    ),
                    PlayerControls(provider: provider),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
