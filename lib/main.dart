import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/providers/rtc_provider.dart';
import 'package:osv2/screens/ble_scan_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:osv2/providers/ble_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ],
  ).then(
    (value) => runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => ConnectedDevice(),
          ),
          ChangeNotifierProxyProvider<ConnectedDevice, Rtc>(
            create: (_) => Rtc(
              DiscoveredDevice(
                  id: '',
                  name: '',
                  serviceData: new Map(),
                  manufacturerData: Uint8List(8),
                  rssi: 0,
                  serviceUuids: [
                    Uuid.parse('762808a9-2cb3-4c0e-be22-8fe3e34134a0')
                  ]),
              FlutterReactiveBle(),
            ),
            update: (_, discoveredDevice, rtc) => Rtc(
                discoveredDevice.device, discoveredDevice.flutterReactiveBle),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}
