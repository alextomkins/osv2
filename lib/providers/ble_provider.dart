import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';

class ConnectedDevice with ChangeNotifier {
  final FlutterReactiveBle _flutterReactiveBle = FlutterReactiveBle();
  List<DiscoveredDevice> _foundBleUARTDevices = [];
  StreamSubscription<DiscoveredDevice>? _scanStream;
  Stream<ConnectionStateUpdate>? _currentConnectionStream;
  StreamSubscription<ConnectionStateUpdate>? _connection;
  bool _scanning = false;
  bool _connected = false;
  String _logTexts = "";
  DiscoveredDevice? _device;
  bool _isConnecting = false;

  bool get isConnecting => _isConnecting;
  FlutterReactiveBle get flutterReactiveBle => _flutterReactiveBle;
  DiscoveredDevice? get device => _device;
  StreamSubscription<ConnectionStateUpdate>? get connection => _connection;
  List<DiscoveredDevice> get foundBleUARTDevices => _foundBleUARTDevices;

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

  void startScan() async {
    bool goForIt = await checkAndroidBLEPermissions();

    if (goForIt) {
      _foundBleUARTDevices = [];
      _scanning = true;
      _scanStream =
          flutterReactiveBle.scanForDevices(withServices: []).listen((device) {
        if (_foundBleUARTDevices.every((element) => element.id != device.id) &&
            device.name.startsWith('OSv2')) {
          _foundBleUARTDevices.add(device);
          _foundBleUARTDevices.sort((a, b) => b.rssi.compareTo(a.rssi));
          notifyListeners();
        }
      }, onError: (Object error) {
        _logTexts = "${_logTexts}ERROR while scanning:$error \n";
      });
    }
    notifyListeners();
  }

  void stopScan() async {
    if (_scanning) {
      await _scanStream!.cancel();
      _scanning = false;
    }
  }

  void disconnect() async {
    if (_connected) {
      await _connection!.cancel();
      _connected = false;
      notifyListeners();
    }
  }

  void onConnectDevice(index) {
    _device = _foundBleUARTDevices[index];
    _currentConnectionStream = flutterReactiveBle.connectToAdvertisingDevice(
      id: _foundBleUARTDevices[index].id,
      prescanDuration: const Duration(seconds: 1),
      withServices: [],
    );
    _logTexts = "";
    _connection = _currentConnectionStream!.listen((event) async {
      var id = event.deviceId.toString();
      switch (event.connectionState) {
        case DeviceConnectionState.connecting:
          {
            _isConnecting = true;
            _logTexts = "${_logTexts}Connecting to $id\n";
            notifyListeners();
            break;
          }
        case DeviceConnectionState.connected:
          {
            _isConnecting = false;
            _connected = true;
            _logTexts = "${_logTexts}Connected to $id\n";
            notifyListeners();
            break;
          }
        case DeviceConnectionState.disconnecting:
          {
            _isConnecting = false;
            _connected = false;
            _logTexts = "${_logTexts}Disconnecting from $id\n";
            notifyListeners();
            break;
          }
        case DeviceConnectionState.disconnected:
          {
            _isConnecting = false;
            _logTexts = "${_logTexts}Disconnected from $id\n";
            notifyListeners();
            break;
          }
      }
    });
  }
}
