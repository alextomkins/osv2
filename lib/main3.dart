// import 'dart:async';
// import 'dart:io' show Platform;
// import 'package:flutter/material.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       home: StreamBuilderPage(),
//     );
//   }
// }

// class StreamBuilderPage extends StatefulWidget {
//   const StreamBuilderPage({super.key});

//   @override
//   _StreamBuilderPageState createState() => _StreamBuilderPageState();
// }

// class _StreamBuilderPageState extends State<StreamBuilderPage> {
//   List<DiscoveredDevice> items = [];
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: StreamBuilder(
//             //Error number 2
//             stream: DeviceScan().stream,
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const CircularProgressIndicator();
//               } else if (snapshot.connectionState == ConnectionState.done) {
//                 return const Text('done');
//               } else if (snapshot.hasError) {
//                 return const Text('Error!');
//               } else {
//                 items.add(snapshot.data);
//                 print(
//                     items); //print every second: [0] then [0,1] then [0,1,2] ...
//                 return ListView.builder(
//                   itemBuilder: (context, index) {
//                     return ListTile(
//                       title: Text(items[index].toString()),
//                     );
//                   },
//                   itemCount: items.length,
//                 );
//               }
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }

// class DeviceScan {
//   final flutterReactiveBle = FlutterReactiveBle();
//   DeviceScan() {
//     flutterReactiveBle.scanForDevices(
//         withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
//       _controller.sink.add(device);
//       //code for handling results
//     }, onError: () {
//       print('error');
//     });
//   }
//   final _controller = StreamController<DiscoveredDevice>();

//   Stream<DiscoveredDevice> get stream => _controller.stream;

//   dispose() {
//     _controller.close();
//   }
// }

// void _startScan() async {
//   bool goForIt = false;
//   PermissionStatus permission;
//   if (Platform.isAndroid) {
//     permission = await LocationPermissions().requestPermissions();
//     if (permission == PermissionStatus.granted) goForIt = true;
//   } else if (Platform.isIOS) {
//     goForIt = true;
//   }
//   if (goForIt) {
//     //TODO replace True with permission == PermissionStatus.granted is for IOS test
//     _foundBleUARTDevices = [];
//     _scanning = true;
//     refreshScreen();
//     _scanStream = flutterReactiveBle
//         .scanForDevices(withServices: [_UART_UUID]).listen((device) {
//       if (_foundBleUARTDevices.every((element) => element.id != device.id)) {
//         _foundBleUARTDevices.add(device);
//         refreshScreen();
//       }
//     }, onError: (Object error) {
//       _logTexts = "${_logTexts}ERROR while scanning:$error \n";
//       refreshScreen();
//     });
//   } else {
//     await showNoPermissionDialog();
//   }
// }
