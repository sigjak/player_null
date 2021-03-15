import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'meta.dart';
import '../../models/station.dart';

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
        source: 'http://stream.live.vc.bbcmedia.co.uk/bbc_world_service',
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

  List<String> audioFiles = [];
  List<AudioSource> workList = [];

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
    // mp3Files.forEach((element) {
    //   if (element.contains(namesOfBooks[0])) {
    //     String temp = element.substring(0, element.length - 4);
    //     temp = temp.substring(18);

    //     playlist.add(
    //       AudioSource.uri(
    //         Uri.parse("asset:///$element"),
    //         tag: AudioMetadata(
    //             album: namesOfBooks[0], title: temp, artwork: figFile[0]),
    //       ),
    //     );
    //   }
    // });
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
      print(playlist);
      playLists.add(playlist);
    }
  }
}
