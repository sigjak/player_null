import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  late ConcatenatingAudioSource _playList;
  bool ready = false;
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    initBooks(index);
  }

  initBooks(index) async {
    final data = Provider.of<DataProvider>(context, listen: false);
    final session = await AudioSession.instance;
    _playList = ConcatenatingAudioSource(children: data.playLists[index]);

    await session.configure(AudioSessionConfiguration.speech());
    await _audioPlayer.setAudioSource(_playList);
    ready = true;
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
      appBar: AppBar(
        title: Text('AudioBooks'),
        actions: [
          TextButton(
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                final myStr = prefs.getStringList('positionIndex') ?? [];
                print('One: ${myStr[0]}-- Two: ${myStr[1]}');
              },
              child: Text('Get')),
          TextButton.icon(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black)),
              onPressed: () async {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.setStringList('positionIndex', [
                  _audioPlayer.position.toString(),
                  _audioPlayer.currentIndex.toString()
                ]);
              },
              icon: Icon(Icons.book),
              label: Text('ChangeBook'))
        ],
      ),
      body: Center(
        child: !ready
            ? CircularProgressIndicator()
            : Column(
                children: [
                  Row(children: [
                    Text(
                      data.namesOfBooks[0].toString(),
                    ),
                  ]),
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
                                    image: AssetImage(
                                        book.sequence[0].tag.artwork),
                                  ),
                                ),
                                Text(book.sequence[0].tag.album,
                                    style: TextStyle(fontSize: 20)),
                                Text(
                                    '${book.sequence[book.currentIndex].tag.title}--${book.currentIndex}')
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
                            'Episodes',
                            style: TextStyle(fontSize: 22),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: _playList.length,
                            itemBuilder: (BuildContext ctx, int index) {
                              return Card(
                                margin: EdgeInsets.fromLTRB(16, 2, 16, 0),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: AssetImage(
                                        _playList.sequence[0].tag.artwork),
                                  ),
                                  title:
                                      Text(_playList.sequence[index].tag.title),
                                  trailing: IconButton(
                                    onPressed: () async {
                                      await _audioPlayer.stop();
                                      _audioPlayer.seek(Duration(seconds: 0),
                                          index: index);

                                      setState(() {});
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
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList('positionIndex', [
            _audioPlayer.position.toString(),
            _audioPlayer.currentIndex.toString()
          ]);
          dispose();
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        },
        child: Icon(Icons.exit_to_app),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
