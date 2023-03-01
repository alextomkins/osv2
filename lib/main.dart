import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/utils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'routes.dart';
import 'dart:io' show Platform;
import 'package:google_fonts/google_fonts.dart';

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
        textTheme: GoogleFonts.nunitoTextTheme(),
        primarySwatch: createMaterialColor(const Color(0xFF353E47)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //darkTheme: ThemeData.dark(),
      home: const MyHomePage(title: 'Ozone Swim'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<int>? initRunMode = [0, 0];
List<int>? initRtc = [0, 0, 0, 0, 0, 1, 0];
List<int>? initCpuStatus = [0, 0];
List<int>? initTimers = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

class _MyHomePageState extends State<MyHomePage> {
  int index = -1;
  final flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  StreamSubscription<DiscoveredDevice>? _scanStream;
  Stream<ConnectionStateUpdate>? _currentConnectionStream;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";

  final Uuid cpuModuleServiceUuid =
      Uuid.parse('388a4ae7-f276-4321-b227-6cd344f0bb7d');
  final Uuid cpuStatusCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a00');
  final Uuid rtcCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a02');
  final Uuid runModeCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a03');
  final Uuid timersCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a07');
  bool isConnecting = false;

  @override
  void initState() {
    _startScan();
    super.initState();
  }

  void refreshScreen() {
    setState(() {});
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
            device.name.startsWith('OSv2')) {
          _foundBleUARTDevices.add(device);
          _foundBleUARTDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

          refreshScreen();
        } else if (device.name.startsWith('OSv2')) {
          int dev = _foundBleUARTDevices
              .indexWhere((element) => element.id == device.id);
          _foundBleUARTDevices[dev] = device;
          _foundBleUARTDevices.sort((a, b) => b.rssi.compareTo(a.rssi));

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
            isConnecting = true;
            _logTexts = "${_logTexts}Connecting to $id\n";
            break;
          }
        case DeviceConnectionState.connected:
          {
            isConnecting = true;
            initCpuStatus = await flutterReactiveBle.readCharacteristic(
                QualifiedCharacteristic(
                    characteristicId: cpuStatusCharacteristicUuid,
                    serviceId: cpuModuleServiceUuid,
                    deviceId: _foundBleUARTDevices[index].id));
            initRtc = await flutterReactiveBle.readCharacteristic(
                QualifiedCharacteristic(
                    characteristicId: rtcCharacteristicUuid,
                    serviceId: cpuModuleServiceUuid,
                    deviceId: _foundBleUARTDevices[index].id));
            initRunMode = await flutterReactiveBle.readCharacteristic(
                QualifiedCharacteristic(
                    characteristicId: runModeCharacteristicUuid,
                    serviceId: cpuModuleServiceUuid,
                    deviceId: _foundBleUARTDevices[index].id));
            initTimers = await flutterReactiveBle.readCharacteristic(
                QualifiedCharacteristic(
                    characteristicId: timersCharacteristicUuid,
                    serviceId: cpuModuleServiceUuid,
                    deviceId: _foundBleUARTDevices[index].id));
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => TurnOn(
                  device: _foundBleUARTDevices[index],
                  flutterReactiveBle: flutterReactiveBle,
                  connection: _connection,
                  cpuStatusData: initCpuStatus,
                  rtcData: initRtc,
                  runModeData: initRunMode,
                  timersData: initTimers,
                ),
              ),
              (Route<dynamic> route) => false,
            );
            _connected = true;
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

  late int selectedIndex = -1;
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            widget.title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 75.0, bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Devices Found",
                      style: TextStyle(
                        fontSize: 32,
                        color: Color.fromRGBO(88, 200, 223, 1),
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _connected ? _disconnect : () {};
                          _foundBleUARTDevices = [];
                          selectedIndex = -1;
                          index = -1;
                          _startScan();
                        },
                        icon: const Icon(Icons.refresh,
                            color: Color.fromRGBO(88, 201, 223, 1)))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.all(20.0),
                height: 300,
                child: ListView.builder(
                  itemCount: _foundBleUARTDevices.length,
                  itemBuilder: (context, index) => Card(
                    child: ListTile(
                      dense: true,
                      tileColor: selectedIndex == index
                          ? const Color.fromRGBO(88, 201, 223, 1)
                          : Colors.transparent,
                      title: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: () {
                            _stopScan();
                            setState(() => selectedIndex = index);
                            this.index = index;
                          },
                          child: Text(
                              //"${_foundBleUARTDevices[index].name} rssi: ${_foundBleUARTDevices[index].rssi}")),
                              _foundBleUARTDevices[index].name)),
                      trailing: Icon(_foundBleUARTDevices[index].rssi >= -67
                          ? Icons.signal_cellular_alt
                          : _foundBleUARTDevices[index].rssi >= -77
                              ? Icons.signal_cellular_alt_2_bar
                              : _foundBleUARTDevices[index].rssi > -90
                                  ? Icons.signal_cellular_alt_1_bar
                                  : Icons.signal_cellular_0_bar),
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: (index > -1) ? true : false,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 115.0, top: 50.0, bottom: 50.0),
                      child: SizedBox(
                        width: 150,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            (!_connected && _scanning) ||
                                    (!_scanning && _connected) ||
                                    (index == -1)
                                ? () {}
                                : onConnectDevice(index);
                          },
                          child: const Text(
                            'Connect',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: isConnecting,
                    child: const Padding(
                      padding: EdgeInsets.only(left: 10.0),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
}
