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
          print("Using IframePlayer for URL: $sourceUrl");
          return IframePlayer(sourceUrl: sourceUrl, provider: provider);
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

class IframePlayer extends StatefulWidget {
  final String sourceUrl;
  final VideoControllerProvider provider;
  const IframePlayer({
    super.key,
    required this.sourceUrl,
    required this.provider,
  });

  @override
  State<IframePlayer> createState() => _IframePlayerState();
}

class _IframePlayerState extends State<IframePlayer> {
  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: InAppWebView(
        key: ValueKey(widget.sourceUrl),
        initialData: InAppWebViewInitialData(
          data: '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8">

<meta
  name="viewport"
  content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no"
>

<meta http-equiv="X-UA-Compatible" content="IE=edge">

<meta http-equiv="Content-Security-Policy" content="default-src * 'unsafe-inline' 'unsafe-eval' data: blob:;">
<style>
* { margin: 0; padding: 0; box-sizing: border-box; }
body { width: 100vw; height: 100vh; overflow: hidden; background: #000; }
iframe { width: 100%; height: 100%; border: none; display: block; }
</style>
</head>

<body>

<iframe
  id="player"
  src="${widget.sourceUrl}"
  width="100%"
  height="100%"
  allow="
    picture-in-picture;
    fullscreen
  "
  allowfullscreen
  webkitallowfullscreen
  mozallowfullscreen
  frameborder="0"
  scrolling="no"
></iframe>
<script>
function sendToFlutter(data) {
  try {
    window.flutter_inappwebview.callHandler('messageHandler', data);
  } catch (e) {}
}

window.addEventListener("message", function(event) {
  let data = event.data;

  if (typeof data === "string") {
    try {
      data = JSON.parse(data);
    } catch (_) {}
  }

  sendToFlutter(data);
});

window.addEventListener("load", () => {
    sendToFlutter({ type: "iframe-loaded" });
  });

setInterval(() => {
  sendToFlutter({
    type: "heartbeat",
    time: Date.now()
  });
}, 15000);
</script>

</body>
</html>
''',

          baseUrl: WebUri("https://megaplay.buzz"),
        ),
        initialSettings: InAppWebViewSettings(
          javaScriptEnabled: true,

          javaScriptCanOpenWindowsAutomatically: true,

          mediaPlaybackRequiresUserGesture: false,

          allowsInlineMediaPlayback: true,

          allowsPictureInPictureMediaPlayback: true,

          iframeAllowFullscreen: true,

          isElementFullscreenEnabled: true,

          useHybridComposition: true,
          hardwareAcceleration: true,

          domStorageEnabled: true,
          databaseEnabled: true,

          thirdPartyCookiesEnabled: true,

          mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,

          transparentBackground: false,

          supportZoom: false,

          allowsBackForwardNavigationGestures: false,

          preferredContentMode: UserPreferredContentMode.MOBILE,

          disableVerticalScroll: true,
          disableHorizontalScroll: true,

          cacheEnabled: true,

          incognito: false,

          algorithmicDarkeningAllowed: false,
        ),
        onWebViewCreated: (webController) {
          webController.addJavaScriptHandler(
            handlerName: 'messageHandler',
            callback: (args) {
              print("ARGS: $args");
              final isWatchingLog = args.first["type"] == "watching-log";
              final isMegacloud = args.first["channel"] == "megacloud";
              if (isWatchingLog || isMegacloud) {
                int seconds =
                    ((isWatchingLog
                                ? args.first["currentTime"]
                                : args.first["time"])
                            as num)
                        .toInt();

                Duration time = Duration(seconds: seconds);

                Duration duration = Duration(
                  seconds: (args.first["duration"] as num).toInt(),
                );

                widget.provider.saveTimecodeFromTime(time, duration);
              }
            },
          );
        },
        onConsoleMessage: (controller, consoleMessage) {
          if (consoleMessage.messageLevel == ConsoleMessageLevel.ERROR) {
            print('WebView Error: ${consoleMessage.message}');
          }
        },
        onReceivedError: (controller, request, error) {
          print('WebView Error: $error');
        },
        onLoadStart: (controller, url) {
          print('Load started: $url');
        },

        onLoadStop: (controller, url) {
          print('Load stopped: $url');
        },

        onProgressChanged: (controller, progress) {
          print('Progress: $progress%');
        },
        onReceivedHttpError: (controller, request, errorResponse) {
          print('${errorResponse.statusCode} | ${request.url}');
        },
        shouldOverrideUrlLoading: (controller, navigationAction) async {
          final url = navigationAction.request.url;

          if (url == null) {
            return NavigationActionPolicy.CANCEL;
          }

          final host = url.host.toLowerCase();
          final fullUrl = url.toString();

          final isAllowed =
              host == 'megaplay.buzz' ||
              host.endsWith('.megaplay.buzz') ||
              fullUrl.startsWith('https://megaplay.buzz');

          if (isAllowed) {
            print('Allowed navigation $fullUrl');
            return NavigationActionPolicy.ALLOW;
          }

          print('Blocked navigation $fullUrl');
          return NavigationActionPolicy.CANCEL;
        },
      ),
    );
  }
}
