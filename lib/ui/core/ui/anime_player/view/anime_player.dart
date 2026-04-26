import 'package:anime_app/data/models/anime.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';
import 'package:anime_app/ui/core/ui/anime_player/widgets/fullscreen_player.dart';
import 'package:anime_app/ui/core/ui/anime_player/widgets/player_controls.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class AnimePlayer extends StatelessWidget {
  final Anime anime;
  final bool isWide;

  const AnimePlayer({super.key, required this.anime, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Consumer<VideoControllerProvider>(
      builder: (context, provider, _) {
        final controller = provider.controller;

        if (provider.currentEpisode == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final sourceUrl = provider.currentEpisode!.sources.first.url;
        final isIframe = !sourceUrl.contains('m3u8');

        if (!isIframe && !(controller?.value.isInitialized ?? false)) {
          return const Center(child: CircularProgressIndicator());
        }

        if (isIframe) {
          return AspectRatio(
            aspectRatio: 16 / 9,
            child: InAppWebView(
              key: ValueKey(sourceUrl),
              initialData: InAppWebViewInitialData(
                data: '''
<!DOCTYPE html>
<html>
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0">
<meta http-equiv="Content-Security-Policy" content="default-src * 'unsafe-inline' 'unsafe-eval' data: blob:;">
<style>
  html, body {
    margin: 0;
    padding: 0;
    height: 100%;
    width: 100%;
    background: black;
    overflow: hidden;
    display: flex;
    justify-content: center;
    align-items: center;
  }

  .player-container {
    width: 100%;
    height: 100%;
    position: relative;
  }

  iframe {
    width: 100%;
    height: 100%;
    border: none;
  }
</style>
</head>

<body>
  <div class="player-container">
    <iframe 
      src="$sourceUrl"
      frameborder="0"
      allow="autoplay; fullscreen; encrypted-media; picture-in-picture"
      allowfullscreen>
    </iframe>
  </div>

<script>
  window.addEventListener("message", function (event) {
    let data = event.data;

    if (typeof data === "string") {
      try {
        data = JSON.parse(data);
      } catch (e) {
        return;
      }
    }

    if (data.channel === "megacloud") {
      window.flutter_inappwebview.callHandler('messageHandler', data);
    }

    if (data.type === "watching-log") {
      window.flutter_inappwebview.callHandler('messageHandler', data);
    }

    // SEND TO FLUTTER
    if (window.flutter_inappwebview) {
      window.flutter_inappwebview.callHandler('messageHandler', data);
    }
  });
</script>

</body>
</html>
                ''',
                mimeType: 'text/html',
                encoding: 'utf-8',
                baseUrl: WebUri("https://anime.local"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                useHybridComposition: true,
                supportZoom: false,
                transparentBackground: true,
                javaScriptCanOpenWindowsAutomatically: true,
                iframeAllowFullscreen: true,
              ),
              onWebViewCreated: (webController) {
                webController.addJavaScriptHandler(
                  handlerName: 'messageHandler',
                  callback: (args) {
                    print('Received message from iframe: ${args.first}');
                  },
                );
              },
              onReceivedError: (controller, request, error) {},
            ),
          );
        }

        return AspectRatio(
          aspectRatio: controller!.value.aspectRatio,
          child: Stack(
            alignment: Alignment.center,
            children: [
              VideoPlayer(controller),

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
                            iconSize: isWide ? 38 : 20,
                            onPressed: provider.seekBackward,
                          ),

                          IconButton(
                            icon: Icon(
                              controller.value.isPlaying
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            iconSize: isWide ? 38 : 20,
                            onPressed: provider.togglePlayPause,
                          ),

                          IconButton(
                            icon: const Icon(
                              Icons.forward_10,
                              color: Colors.white,
                            ),
                            iconSize: isWide ? 38 : 20,
                            onPressed: provider.seekForward,
                          ),

                          IconButton(
                            iconSize: isWide ? 38 : 20,
                            icon: const Icon(
                              Icons.fullscreen,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => FullscreenPlayer(
                                        provider: provider,
                                        isWide: isWide,
                                        anime: anime,
                                      ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    PlayerControls(provider: provider, isWide: isWide),
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
