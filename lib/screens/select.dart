import 'package:audioplayer_null/screens/audiobookPlayer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'radio_player.dart';
import '../helpers/data_provider.dart';

class Selecting extends StatefulWidget {
  @override
  _SelectingState createState() => _SelectingState();
}

class _SelectingState extends State<Selecting> {
  @override
  void initState() {
    super.initState();
    _initBooks();
  }

  _initBooks() async {
    final data = Provider.of<DataProvider>(context, listen: false);
    await data.getAssetFiles();
  }

  @override
  Widget build(BuildContext context) {
    //final data = Provider.of<DataProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Audioplayer'),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('assets/images/grey.png'), fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 3,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => Player()));
                    },
                    child: Image.asset('assets/images/bw_radio.png')),
              ),
              Container(
                height: MediaQuery.of(context).size.height / 4,
                child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => BookPlayer()));
                    },
                    child: Image.asset('assets/images/audioBook2.png')),
              ),
            ],
          ),
        ));
  }
}
