import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart';
import 'package:just_audio/just_audio.dart';

class RadioSlider extends StatelessWidget {
  const RadioSlider(this._audioPlayer);
  final AudioPlayer _audioPlayer;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        StreamBuilder<PositionData>(
            stream: Rx.combineLatest2<Duration, Duration, PositionData>(
              _audioPlayer.positionStream,
              _audioPlayer.bufferedPositionStream,
              (position, bufferedPosition) =>
                  PositionData(position, bufferedPosition),
            ),
            builder: (context, snapshot) {
              final positionData =
                  snapshot.data ?? PositionData(Duration.zero, Duration.zero);
              var position = positionData.position;
              var bufferedposition = positionData.bufferedPosition;
              return Text(
                  'Pos: ${position.toString().split(".").first} Buff: ${bufferedposition.toString().split(".").first}');
              // compare with duration from another Streambuilder
            })
      ],
    );
  }
}

class PositionData {
  final Duration position;
  final Duration bufferedPosition;
  PositionData(this.position, this.bufferedPosition);
}
