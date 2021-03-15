import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class PlayerButtons extends StatelessWidget {
  const PlayerButtons(this._audioPlayer, this.isRadio, {Key? key})
      : super(key: key);
  final AudioPlayer _audioPlayer;
  final isRadio;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        isRadio
            ? SizedBox()
            : StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (_, snapshot) {
                  final pos = snapshot.data;

                  return IconButton(
                      icon: Icon(Icons.forward_10),
                      onPressed: () async {
                        Duration seeking = pos! + Duration(seconds: 10);
                        await _audioPlayer.seek(seeking);
                      });
                }),
        StreamBuilder<SequenceState?>(
          stream: _audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            return _previousButton();
          },
        ),
        StreamBuilder<PlayerState>(
          stream: _audioPlayer.playerStateStream,
          builder: (_, snapshot) {
            final playerState = snapshot.data;

            return _playPauseButton(playerState);
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: _audioPlayer.sequenceStateStream,
          builder: (context, snapshot) {
            return _nextButton();
          },
        ),
        isRadio
            ? SizedBox()
            : StreamBuilder<Duration>(
                stream: _audioPlayer.positionStream,
                builder: (_, snapshot) {
                  final pos = snapshot.data;
                  return IconButton(
                      icon: Icon(Icons.replay_10),
                      onPressed: () async {
                        Duration seeking = pos! - Duration(seconds: 10);
                        await _audioPlayer.seek(seeking);
                      });
                }),
      ],
    );
  }

  Widget _playPauseButton(PlayerState? playerState) {
    final processingState = playerState?.processingState;
    if (processingState == ProcessingState.loading ||
        processingState == ProcessingState.buffering) {
      return Container(
        margin: EdgeInsets.all(8.0),
        width: 64.0,
        height: 64.0,
        child: CircularProgressIndicator(),
      );
    } else if (_audioPlayer.playing != true) {
      return IconButton(
        icon: Icon(Icons.play_arrow),
        iconSize: 64.0,
        onPressed: _audioPlayer.play,
      );
    } else if (processingState != ProcessingState.completed) {
      return IconButton(
        icon: Icon(Icons.pause),
        iconSize: 64.0,
        onPressed: _audioPlayer.pause,
      );
    } else {
      return IconButton(
        icon: Icon(Icons.replay),
        iconSize: 64.0,
        onPressed: () => _audioPlayer.seek(Duration.zero,
            index: _audioPlayer.effectiveIndices?.first),
      );
    }
  }

  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
    );
  }
}
