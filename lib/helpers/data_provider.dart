import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/meta.dart';
import '../models/station.dart';

class DataProvider with ChangeNotifier {
  late int numberOfBooks;
  late List<dynamic> namesOfBooks;
  late List<dynamic> figFile;
  late List<String> mp3Files;
  List<AudioSource> playlist = [];
  List<List<AudioSource>> playLists = [];
  List<Station> stations = [
    Station(
        name: 'BBC World Service',
        // BBC is a Dash audio see radio
        source:
            'https://a.files.bbci.co.uk/media/live/manifesto/audio/simulcast/dash/nonuk/dash_low/aks/bbc_world_service.mpd',
        //source: 'http://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
        logo: 'assets/images/bbc.png'),
    Station(
        name: 'WNYC 93.9',
        source: 'http://fm939.wnyc.org/wnycfm',
        logo: 'assets/images/wnyc.png'),
    Station(
        name: 'RUV Rás 1',
        source: 'http://netradio.ruv.is/ras1.mp3',
        logo: 'assets/images/ras_1.png'),
    Station(
        name: 'RUV Rás 2',
        source: 'http://netradio.ruv.is/ras2.mp3',
        logo: 'assets/images/ras_2.png'),
    Station(
        name: 'WAMU',
        source: 'http://wamu-1.streamguys.com',
        logo: 'assets/images/wamu.png'),
    Station(
        name: 'WBUR',
        source: 'https://icecast-stream.wbur.org/wbur',
        logo: 'assets/images/wbur.png'),
    Station(
        name: 'Bylgjan',
        source: 'http://stream3.radio.is:443/tbylgjan',
        logo: 'assets/images/bylgjan.png'),
  ];

  //List<String> audioFiles = [];
  //List<AudioSource> workList = [];

  Future<void> getAssetFiles() async {
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = jsonDecode(manifestContent);
    mp3Files = manifestMap.keys.where((key) => key.contains('.mp3')).toList();
    // clean empty spaces
    for (var i = 0; i < mp3Files.length; i++) {
      mp3Files[i] = mp3Files[i].replaceAll('%20', ' ');
    }

    String infoJson =
        await rootBundle.loadString('assets/files/infoBooks.json');
    var infoMap = jsonDecode(infoJson);
    numberOfBooks = infoMap["numberOfBooks"];
    namesOfBooks = infoMap['namesOfBooks'];
    figFile = infoMap['artwork'];
    prepPlaylist();
  }

  prepPlaylist() {
    for (var i = 0; i < numberOfBooks; i++) {
      playlist = [];
      mp3Files.forEach((element) {
        if (element.contains(namesOfBooks[i])) {
          String temp = element.substring(0, element.length - 4);
          temp = temp.substring(18);
          playlist.add(
            AudioSource.uri(
              Uri.parse("asset:///$element"),
              tag: AudioMetadata(
                  album: namesOfBooks[i], title: temp, artwork: figFile[i]),
            ),
          );
        }
      });

      playLists.add(playlist);
    }
  }

  Duration parseDuration(String s) {
    int hours = 0;
    int minutes = 0;
    int micros;
    List<String> parts = s.split(':');
    if (parts.length > 2) {
      hours = int.parse(parts[parts.length - 3]);
    }
    if (parts.length > 1) {
      minutes = int.parse(parts[parts.length - 2]);
    }
    micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
    return Duration(hours: hours, minutes: minutes, microseconds: micros);
  }

  checkfRefs(_audioPlayer) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final prefList = prefs.getStringList('positionIndex') ?? [];
    if (prefList.isEmpty) {
      print('empty');
      return;
    } else {
      String book = prefList[0];

      Duration lastPosition = parseDuration(prefList[1]) - Duration(seconds: 5);
      int lastSequence = int.parse(prefList[2]);
      if (book == _audioPlayer.sequence?[0].tag.album) {
        _audioPlayer.seek(lastPosition, index: lastSequence);
      }
    }
  }
}
