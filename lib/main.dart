import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter_reactive_ble example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const MyHomePage(title: 'Flutter_reactive_ble UART example'),
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
  StreamSubscription<DiscoveredDevice>? _scanStream;
  Stream<ConnectionStateUpdate>? _currentConnectionStream;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  Stream<List<int>>? _receivedDataStream;
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";
  List<String> _receivedData = [];
  int _numberOfMessagesReceived = 0;

  @override
  void initState() {
    super.initState();
  }

  void refreshScreen() {
    setState(() {});
  }

  void onNewReceivedData(List<int> data) {
    _numberOfMessagesReceived += 1;
    _receivedData
        .add("$_numberOfMessagesReceived: ${String.fromCharCodes(data)}");
    if (_receivedData.length > 5) {
      _receivedData.removeAt(0);
    }
    refreshScreen();
  }

  void _disconnect() async {
    await _connection!.cancel();
    _connected = false;
    refreshScreen();
  }

  void _stopScan() async {
    await _scanStream!.cancel();
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

  Future<bool> checkAndroidBLEPermissions() async {
    if (Platform.isAndroid) {
      bool isLocation = true,
          isBlScan = true,
          isBlAdvertise = true,
          isBleConn = true;

      Map<Permission, PermissionStatus> statuses = await [
        Permission.location,
        Permission.bluetoothScan,
        Permission.bluetoothAdvertise,
        Permission.bluetoothConnect
      ].request();
      for (var status in statuses.entries) {
        if (status.key == Permission.location) {
          if (!status.value.isGranted) isLocation = false;
        } else if (status.key == Permission.bluetoothScan) {
          if (!status.value.isGranted) isBlScan = false;
        } else if (status.key == Permission.bluetoothAdvertise) {
          if (!status.value.isGranted) isBlAdvertise = false;
        } else if (status.key == Permission.bluetoothConnect) {
          if (!status.value.isGranted) isBleConn = false;
        }

        if (isLocation == false ||
            isBlScan == false ||
            isBlAdvertise == false ||
            isBleConn == false) {
          return Future.value(false);
        }
      }
    }
    return Future.value(true);
  }

  void _startScan() async {
    bool goForIt = await checkAndroidBLEPermissions();

    if (goForIt) {
      _foundBleUARTDevices = [];
      _scanning = true;
      refreshScreen();
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        if (_foundBleUARTDevices.every((element) => element.id != device.id) &&
            device.name != '') {
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

  void onConnectDevice(index) {
    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id: _foundBleUARTDevices[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [],
    );
    _logTexts = "";
    refreshScreen();
    _connection = _currentConnectionStream!.listen((event) async {
      var id = event.deviceId.toString();
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            _logTexts = "${_logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            final Uuid serviceUuid =
                Uuid.parse('59462f12-9543-9999-12c8-58b459a2712d');
            final Uuid characteristicUuid =
                Uuid.parse('5c3a659e-897e-45e1-b016-007107c96df6');
            final characteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: _foundBleUARTDevices[index].id);
            final response =
                await flutterReactiveBle.readCharacteristic(characteristic);
            print(response);
            _connected = true;
            _logTexts = "${_logTexts}Connected to $id\n";
            _numberOfMessagesReceived = 0;
            _receivedData = [];
            _receivedDataStream?.listen((data) {
              onNewReceivedData(data);
            }, onError: (dynamic error) {
              _logTexts = "${_logTexts}Error:$error$id\n";
            });
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            _connected = false;
            _logTexts = "${_logTexts}Disconnecting from $id\n";
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            _logTexts = "${_logTexts}Disconnected from $id\n";
            break;
          }
      }
      refreshScreen();
    });
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
                  height: 300,
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
                                    : onConnectDevice(index);
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
              const Text("Status messages:"),
              Container(
                  margin: const EdgeInsets.all(3.0),
                  width: 1400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue, width: 2)),
                  height: 90,
                  child: Scrollbar(
                      child: SingleChildScrollView(child: Text(_logTexts)))),
              const Text("Received data:"),
              Container(
                  margin: const EdgeInsets.all(3.0),
                  width: 1400,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue, width: 2)),
                  height: 90,
                  child: Text(_receivedData.join("\n"))),
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
