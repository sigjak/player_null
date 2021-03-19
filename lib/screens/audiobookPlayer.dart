import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../commons/player_buttons.dart';
import '../helpers/data_provider.dart';
import '../commons/slider.dart';

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

// index is # of book selected
  initBooks(index) async {
    //check if Shared prefs available

    final data = Provider.of<DataProvider>(context, listen: false);
    final session = await AudioSession.instance;
    _playList = ConcatenatingAudioSource(children: data.playLists[index]);

    await session.configure(AudioSessionConfiguration.speech());
    await _audioPlayer.setAudioSource(_playList);
    await data.checkfRefs(_audioPlayer);
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
            child: Text('Set'),
            style: TextButton.styleFrom(primary: Colors.black),
            onPressed: () async {
              SharedPreferences prefs = await SharedPreferences.getInstance();
              prefs.setStringList('positionIndex', [
                _audioPlayer.sequence?[0].tag.album,
                _audioPlayer.position.toString(),
                _audioPlayer.currentIndex.toString()
              ]);
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/grey.png'), fit: BoxFit.cover),
        ),
        child: Center(
          child: !ready
              ? CircularProgressIndicator()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(children: [
                        Container(
                          padding: EdgeInsets.only(left: 20),
                          height: 80.0,
                          width: MediaQuery.of(context).size.width,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: data.figFile.length,
                            itemBuilder: (BuildContext context, int index) {
                              return GestureDetector(
                                onTap: () {
                                  initBooks(index);
                                },
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: Image(
                                      image: AssetImage(data.figFile[index])),
                                ),
                              );
                            },
                          ),
                        ),
                      ]),
                    ),
                    Divider(
                      thickness: 3,
                      indent: 40,
                      endIndent: 40,
                    ),
                    Container(
                      height: MediaQuery.of(context).size.height / 4,
                      child: StreamBuilder<SequenceState?>(
                          stream: _audioPlayer.sequenceStateStream,
                          builder: (_, snapshot) {
                            final book = snapshot.data;

                            return book != null
                                ? Column(children: [
                                    Container(
                                      margin:
                                          EdgeInsets.symmetric(vertical: 20),
                                      height: 120,
                                      child: Image(
                                        image: AssetImage(
                                            book.sequence[0].tag.artwork),
                                      ),
                                    ),
                                    Text(book.sequence[0].tag.album,
                                        style: TextStyle(fontSize: 20)),
                                    Text(book
                                        .sequence[book.currentIndex].tag.title)
                                  ])
                                : Text('');
                          }),
                    ),
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
                                    leading: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxHeight: 32),
                                      child: Image(
                                          image: AssetImage(_playList
                                              .sequence[0].tag.artwork)),
                                    ),
                                    // leading: CircleAvatar(
                                    //   backgroundImage: AssetImage(
                                    //       _playList.sequence[0].tag.artwork),
                                    // ),
                                    title: Text(
                                        _playList.sequence[index].tag.title),
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
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.grey[600],
        onPressed: () async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setStringList('positionIndex', [
            _audioPlayer.sequence?[0].tag.album,
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
