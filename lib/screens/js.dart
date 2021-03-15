import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../models/station.dart';

class GetJson extends StatefulWidget {
  @override
  _GetJsonState createState() => _GetJsonState();
}

class _GetJsonState extends State<GetJson> {
  Future get() async {
    String gg = await rootBundle.loadString('assets/files/infoBooks.json');
    // print(gg);
    List<dynamic> ll = [];
    List<dynamic> dec = json.decode(gg);
    dec.forEach((element) {
      ll.add(Station.fromJson(element));
    });
    print(ll[1].isRadio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ElevatedButton(
          child: Text('GetJS'),
          onPressed: () async {
            await get();
          },
        ));
  }
}
