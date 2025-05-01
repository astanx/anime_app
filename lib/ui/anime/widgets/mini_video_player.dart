import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';

class MiniVideoPlayer extends StatefulWidget {
  final VideoControllerProvider provider;
  const MiniVideoPlayer({super.key, required this.provider});

  @override
  State<MiniVideoPlayer> createState() => _MiniVideoPlayerState();
}

class _MiniVideoPlayerState extends State<MiniVideoPlayer> {
  final double _miniPlayerHeight = 200;
  final double _miniPlayerWidth = 120;
  Offset _position = Offset(
    WidgetsBinding.instance.window.physicalSize.width / 2 - 60,
    WidgetsBinding.instance.window.physicalSize.height / 2 - 100,
  );

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            _position += details.delta;
          });
        },
        child: Container(
          width: _miniPlayerWidth,
          height: _miniPlayerHeight,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            children: [
              if (widget.provider.controller != null)
                VideoPlayer(widget.provider.controller!),
              Positioned(
                top: 4,
                right: 4,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    widget.provider.closeMiniPlayer();
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Center(
                child: IconButton(
                  icon: Icon(
                    widget.provider.controller?.value.isPlaying ?? false
                        ? Icons.pause
                        : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                  onPressed: widget.provider.togglePlayPause,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
