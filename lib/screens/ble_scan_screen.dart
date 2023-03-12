import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:osv2/providers/rtc_provider.dart';
import 'package:osv2/screens/home_screen.dart';
import 'package:osv2/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:osv2/providers/ble_provider.dart';

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
      home: const BleScanScreen(title: 'Ozone Swim v2'),
    );
  }
}

class BleScanScreen extends StatefulWidget {
  const BleScanScreen({Key? key, required this.title}) : super(key: key);
  final String title;
  @override
  State<BleScanScreen> createState() => _BleScanScreenState();
}

class _BleScanScreenState extends State<BleScanScreen> {
  @override
  void initState() {
    context.read<ConnectedDevice>().startScan();
    super.initState();
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

  int selectedIndex = -1;
  int index = -1;
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
                          context.read<ConnectedDevice>().disconnect();
                          context.read<ConnectedDevice>().stopScan();
                          selectedIndex = -1;
                          index = -1;

                          context.read<ConnectedDevice>().startScan();
                        },
                        icon: const Icon(Icons.refresh,
                            color: Color.fromRGBO(88, 201, 223, 1)))
                  ],
                ),
              ),
              Stack(children: [
                Visibility(
                    visible: context
                        .watch<ConnectedDevice>()
                        .foundBleUARTDevices
                        .isEmpty,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: SizedBox(
                          height: 200,
                          width: 300,
                          child: Text(
                            'Press and Hold the Bluetooth Pairing Button on your Ozone Swim v2',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF353E47), fontSize: 25.0),
                          ),
                        ),
                      ),
                    )),
                Container(
                  margin: const EdgeInsets.all(20.0),
                  height: 300,
                  child: ListView.builder(
                    itemCount: context
                        .watch<ConnectedDevice>()
                        .foundBleUARTDevices
                        .length,
                    itemBuilder: (context, index) => Card(
                      child: ListTile(
                        dense: true,
                        tileColor: selectedIndex == index
                            ? const Color.fromRGBO(88, 201, 223, 1)
                            : Colors.transparent,
                        title: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              context.read<ConnectedDevice>().stopScan();
                              setState(() => selectedIndex = index);
                              this.index = index;
                            },
                            child: Text(
                                //"${_foundBleUARTDevices[index].name} rssi: ${_foundBleUARTDevices[index].rssi}")),
                                context
                                    .watch<ConnectedDevice>()
                                    .foundBleUARTDevices[index]
                                    .name)),
                        trailing: Icon(context
                                    .watch<ConnectedDevice>()
                                    .foundBleUARTDevices[index]
                                    .rssi >=
                                -67
                            ? Icons.signal_cellular_alt
                            : context
                                        .watch<ConnectedDevice>()
                                        .foundBleUARTDevices[index]
                                        .rssi >=
                                    -77
                                ? Icons.signal_cellular_alt_2_bar
                                : context
                                            .watch<ConnectedDevice>()
                                            .foundBleUARTDevices[index]
                                            .rssi >
                                        -90
                                    ? Icons.signal_cellular_alt_1_bar
                                    : Icons.signal_cellular_0_bar),
                      ),
                    ),
                  ),
                ),
              ]),
              Row(
                children: [
                  Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: index > -1,
                    child: Padding(
                      padding: const EdgeInsets.only(
                          left: 115.0, top: 50.0, bottom: 50.0),
                      child: SizedBox(
                        width: 150,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () async {
                            context
                                .read<ConnectedDevice>()
                                .onConnectDevice(index);
                            await Future.delayed(const Duration(seconds: 5));
                            context.read<Rtc>().initStream(context);
                            context.read<Rtc>().computeTime();
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                              (Route<dynamic> route) => false,
                            );
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
                    visible: context.watch<ConnectedDevice>().isConnecting,
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
