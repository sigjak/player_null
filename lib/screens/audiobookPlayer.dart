import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'commons/player_buttons.dart';
//import 'helpers/meta.dart';
import 'helpers/data_provider.dart';
import './commons/slider.dart';

class BookPlayer extends StatefulWidget {
  // final int index;
  // const Player(this.index);
  @override
  _BookPlayerState createState() => _BookPlayerState();
}

class _BookPlayerState extends State<BookPlayer> {
  late AudioPlayer _audioPlayer;
  int index = 1;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    initBooks(index);
  }

  initBooks(index) async {
    final data = Provider.of<DataProvider>(context, listen: false);
    final session = await AudioSession.instance;
    final _playList = ConcatenatingAudioSource(children: data.playLists[index]);

    await session.configure(AudioSessionConfiguration.speech());
    await _audioPlayer.setAudioSource(_playList);
    setState(() {});
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
    print('dispose');
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    return Scaffold(
      backgroundColor: Colors.grey[400],
      appBar: AppBar(title: Text('Audioplayer')),
      body: Center(
        child: Column(
          children: [
            StreamBuilder<SequenceState?>(
                stream: _audioPlayer.sequenceStateStream,
                builder: (_, snapshot) {
                  final book = snapshot.data;

                  return book != null
                      ? Column(children: [
                          Container(
                            margin: EdgeInsets.symmetric(vertical: 20),
                            height: 200,
                            child: Image(
                              image: AssetImage(book.sequence[0].tag.artwork),
                            ),
                          ),
                          Text(book.sequence[0].tag.album,
                              style: TextStyle(fontSize: 20)),
                          Text(book.sequence[book.currentIndex].tag.title)
                        ])
                      : Text('');
                }),
            PlayerButtons(_audioPlayer, false),
            SliderBar(_audioPlayer),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'Radio Stations',
                      style: TextStyle(fontSize: 22),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.stations.length,
                      itemBuilder: (BuildContext ctx, int index) {
                        return Card(
                          margin: EdgeInsets.fromLTRB(16, 2, 16, 0),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage(data.stations[index].logo),
                            ),
                            title: Text(data.stations[index].name),
                            trailing: IconButton(
                              onPressed: () async {
                                await _audioPlayer.stop();
                                initBooks(index);
                              },
                              icon: Icon(Icons.play_arrow),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 26)
                ],
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[600],
        onPressed: () {
          dispose();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: Icon(Icons.exit_to_app),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
