// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import '../screens/player.dart';
// import './helpers/data_provider.dart';

// class Selecting extends StatefulWidget {
//   @override
//   _SelectingState createState() => _SelectingState();
// }

// class _SelectingState extends State<Selecting> {
//   @override
//   void initState() {
//     super.initState();
//     _initBooks();
//   }

//   _initBooks() async {
//     final data = Provider.of<DataProvider>(context, listen: false);
//     await data.getAssetFiles();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = Provider.of<DataProvider>(context);
//     return Scaffold(
//         appBar: AppBar(),
//         body: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Column(
//             children: [
//               RowWidget(items: data.stations, textString: 'Radio'),
//               // RowWidget(
//               //   data: data,
//               //   textString: 'Audiobooks',
//               // )
//             ],
//           ),
//         ));
//   }
// }

// class RowWidget extends StatelessWidget {
//   const RowWidget({required this.items, required this.textString});
//   final String textString;
//   final List items;

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: EdgeInsets.only(top: 16),
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.black12,
//         border: Border.all(color: Colors.black),
//       ),
//       child: Stack(
//         children: [
//           Positioned(
//             top: 10,
//             left: 12,
//             child: Text(
//               textString,
//               style: TextStyle(fontSize: 22),
//             ),
//           ),
//           ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: items.length,
//               itemBuilder: (BuildContext context, int index) {
//                 return Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: GestureDetector(
//                     onTap: () {
//                       // print(items[index].source);
//                       Navigator.of(context).push(
//                         MaterialPageRoute(
//                           builder: (context) => Player(index),
//                         ),
//                       );
//                     },
//                     child: Image(
//                       height: 100,
//                       width: 100,
//                       image: AssetImage(items[index].logo),
//                     ),
//                   ),
//                 );
//               }),
//         ],
//       ),
//     );
//   }
// }
