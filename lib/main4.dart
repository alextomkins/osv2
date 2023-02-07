import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:location_permissions/location_permissions.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSv2',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'OSv2'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  late StreamSubscription<DiscoveredDevice> _scanStream;
  late StreamSubscription<ConnectionStateUpdate> _connection;
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";

  void refreshScreen() {
    setState(() {});
  }

  void _disconnect() async {
    await _connection.cancel();
    _connected = false;
    refreshScreen();
  }

  void _stopScan() async {
    await _scanStream.cancel();
    _scanning = false;
    refreshScreen();
  }

  Future<void> showNoPermissionDialog() async => showDialog<void>(
        context: context,
        barrierDismissible: false, // user must tap button!
        builder: (BuildContext context) => AlertDialog(
          title: const Text('No location permission '),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('No location permission granted.'),
                Text('Location permission is required for BLE to function.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Acknowledge'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );

  void _startScan() async {
    bool goForIt = false;
    PermissionStatus permission;
    if (Platform.isAndroid) {
      permission = await LocationPermissions().requestPermissions();
      if (permission == PermissionStatus.granted) goForIt = true;
    } else if (Platform.isIOS) {
      goForIt = true;
    }
    if (goForIt) {
      _foundBleUARTDevices = [];
      _scanning = true;
      refreshScreen();
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        if (_foundBleUARTDevices.every((element) => element.id != device.id)) {
          _foundBleUARTDevices.add(device);
          refreshScreen();
        }
      }, onError: (Object error) {
        _logTexts = "${_logTexts}ERROR while scanning:$error \n";
        refreshScreen();
      });
    } else {
      await showNoPermissionDialog();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text("BLE Devices found:"),
              Container(
                  margin: const EdgeInsets.all(3.0),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue, width: 2)),
                  height: 400,
                  child: ListView.builder(
                      itemCount: _foundBleUARTDevices.length,
                      itemBuilder: (context, index) => Card(
                              child: ListTile(
                            dense: true,
                            enabled: !((!_connected && _scanning) ||
                                (!_scanning && _connected)),
                            trailing: GestureDetector(
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                (!_connected && _scanning) ||
                                        (!_scanning && _connected)
                                    ? () {}
                                    : print;
                              },
                              child: Container(
                                width: 48,
                                height: 48,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4.0),
                                alignment: Alignment.center,
                                child: const Icon(Icons.add_link),
                              ),
                            ),
                            subtitle: Text(_foundBleUARTDevices[index].id),
                            title: Text(
                                "$index: ${_foundBleUARTDevices[index].name}"),
                          )))),
            ],
          ),
        ),
        persistentFooterButtons: [
          SizedBox(
            height: 35,
            child: Column(
              children: [
                if (_scanning)
                  const Text("Scanning: Scanning")
                else
                  const Text("Scanning: Idle"),
                if (_connected)
                  const Text("Connected")
                else
                  const Text("disconnected."),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: !_scanning && !_connected ? _startScan : () {},
            child: Icon(
              Icons.play_arrow,
              color: !_scanning && !_connected ? Colors.blue : Colors.grey,
            ),
          ),
          ElevatedButton(
              onPressed: _scanning ? _stopScan : () {},
              child: Icon(
                Icons.stop,
                color: _scanning ? Colors.blue : Colors.grey,
              )),
          ElevatedButton(
              onPressed: _connected ? _disconnect : () {},
              child: Icon(
                Icons.cancel,
                color: _connected ? Colors.blue : Colors.grey,
              ))
        ],
      );
}
