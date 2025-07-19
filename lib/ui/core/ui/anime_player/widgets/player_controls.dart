import 'package:anime_app/core/utils/format_duration.dart';
import 'package:flutter/material.dart';
import 'package:anime_app/data/provider/video_controller_provider.dart';

class PlayerControls extends StatefulWidget {
  final VideoControllerProvider provider;

  const PlayerControls({super.key, required this.provider});

  @override
  State<PlayerControls> createState() => _PlayerControlsState();
}

class _PlayerControlsState extends State<PlayerControls> {
  bool _isDragging = false;
  bool _isReversedTimer = true;
  double _desiredPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    final controller = widget.provider.controller;
    if (controller == null || !controller.value.isInitialized) {
      return const SizedBox.shrink();
    }

    final position = controller.value.position;
    final duration = controller.value.duration;

    if (_isDragging) {
      setState(() {
        _isDragging =
            position.inSeconds.toDouble() >= _desiredPosition + 10 ||
            position.inSeconds.toDouble() <= _desiredPosition - 10;
      });
    }
    double sliderValue =
        _isDragging ? _desiredPosition : position.inSeconds.toDouble();
    sliderValue = sliderValue.clamp(0.0, duration.inSeconds.toDouble());

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                formatDuration(Duration(seconds: sliderValue.toInt())),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: Colors.white,
                ),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _isReversedTimer
                      ? '-${formatDuration(duration - Duration(seconds: sliderValue.toInt()))}'
                      : formatDuration(duration),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                ),

                onPressed:
                    () => setState(() {
                      _isReversedTimer = !_isReversedTimer;
                    }),
              ),
            ],
          ),
        ),
        Slider(
          activeColor: Colors.white,
          inactiveColor: Colors.grey[600],
          value: sliderValue,
          min: 0,
          max: duration.inSeconds.toDouble(),
          onChanged: (value) {
            setState(() {
              _isDragging = true;
              _desiredPosition = value;
            });
          },
          onChangeEnd: (value) {
            widget.provider.seek(Duration(seconds: value.toInt()));
          },
        ),
      ],
    );
  }
}
