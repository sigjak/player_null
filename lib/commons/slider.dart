import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SliderBar extends StatefulWidget {
  const SliderBar(this._audioPlayer);
  final AudioPlayer _audioPlayer;

  @override
  _SliderBarState createState() => _SliderBarState();
}

class _SliderBarState extends State<SliderBar> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration?>(
        stream: widget._audioPlayer.durationStream,
        builder: (context, snapshot1) {
          final duration = snapshot1.data ?? Duration.zero;
          return StreamBuilder<Duration>(
              stream: widget._audioPlayer.positionStream,
              builder: (context, snapshot2) {
                Duration position = snapshot2.data ?? Duration.zero;

                if (position > duration) {
                  position = duration;
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Stack(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Slider(
                              activeColor: Colors.grey[700],
                              inactiveColor: Colors.grey[300],
                              min: 0.0,
                              max: duration.inMilliseconds.toDouble(),
                              value: position.inMilliseconds.toDouble(),
                              onChanged: (value) {
                                setState(() {
                                  widget._audioPlayer.seek(
                                      Duration(milliseconds: value.toInt()));
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      Positioned(
                          top: 30,
                          child: Text(position.toString().split(".").first)),
                      Positioned(
                          top: 30,
                          right: 0,
                          child: Text(duration.toString().split(".").first)),
                    ],
                  ),
                );
              });
        });
  }
}
