import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

void initBle() {
  final flutterReactiveBle = FlutterReactiveBle();

  flutterReactiveBle.scanForDevices(
      withServices: [], scanMode: ScanMode.lowLatency).listen((device) {
    print(device);
  }, onError: () {
    //code for handling error
  });
}
