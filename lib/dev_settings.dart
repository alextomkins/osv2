import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DevSettings extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;

  const DevSettings({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
  }) : super(key: key);

  @override
  State<DevSettings> createState() => _DevSettingsState();
}

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;
var transformerSize = [
  '250VA / 240v',
  '400VA / 240v',
  '600VA / 240v',
  '250VA / 120v',
  '400VA / 120v',
  '600VA / 120v',
];

class _DevSettingsState extends State<DevSettings> {
  final Uuid cpuModuleserviceUuid =
      Uuid.parse('388a4ae7-f276-4321-b227-6cd344f0bb7d');

  final Uuid cpuStatusCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a00');
  final Uuid rtcCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a02');
  final Uuid runModeCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a03');
  final Uuid commandCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a06');
  final Uuid timersCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a07');

  Stream<List<int>>? cpuStatusSubscriptionStream;
  Stream<List<int>>? rtcSubscriptionStream;
  Stream<List<int>>? runModeSubscriptionStream;
  List<int>? runModeData = [0, 0];
  List<int>? rtcData = [0, 0, 0, 0, 0, 1, 0];
  List<int>? cpuStatusData = [0, 0];
  int runMode = 0;
  DateTime timer1Start = DateTime.now();
  DateTime timer1End = DateTime.now();
  Duration timer1Duration = const Duration(minutes: 0);
  final today = DateTime.now();

  Future<void> _initData() async {
    setState(() {});
  }

  void _initStream() {
    cpuStatusSubscriptionStream = widget.flutterReactiveBle
        .subscribeToCharacteristic(QualifiedCharacteristic(
            characteristicId: cpuStatusCharacteristicUuid,
            serviceId: cpuModuleserviceUuid,
            deviceId: widget.device.id));
    rtcSubscriptionStream = widget.flutterReactiveBle.subscribeToCharacteristic(
        QualifiedCharacteristic(
            characteristicId: rtcCharacteristicUuid,
            serviceId: cpuModuleserviceUuid,
            deviceId: widget.device.id));
    runModeSubscriptionStream = widget.flutterReactiveBle
        .subscribeToCharacteristic(QualifiedCharacteristic(
            characteristicId: runModeCharacteristicUuid,
            serviceId: cpuModuleserviceUuid,
            deviceId: widget.device.id));

    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
    _initData();
    _initStream();
  }

  var items = [
    'Item 1',
    'Item 2',
    'Item 3',
    'Item 4',
    'Item 5',
  ];
  @override
  Widget build(BuildContext context) {
    String dropdownvalue = 'Item 1';

    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Settings",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  const Text('Settings'),
                  const Text('Devide ID'),
                  const Text('OSv2-A-000'),
                  const Text('Transformer Size'),
                  // DropdownButton(
                  //   // Initial Value
                  //   value: dropdownvalue,

                  //   // Down Arrow Icon
                  //   icon: const Icon(Icons.keyboard_arrow_down),

                  //   // Array list of items
                  //   items: items.map((String items) {
                  //     return DropdownMenuItem(
                  //       value: items,
                  //       child: Text(items),
                  //     );
                  //   }).toList(),
                  //   // After selecting the desired option,it will
                  //   // change button value to selected value
                  //   onChanged: (String? newValue) {
                  //     setState(() {
                  //       dropdownvalue = newValue!;
                  //     });
                  //   },
                  // ),
                  const Text('Cell Model'),
                  const Text('30kL'),
                  const Text('Other Parameters'),
                  const Text('Manufacturer Name'),
                  const Text('Serial Number'),
                  const Text('Hardware Revision'),
                  const Text('Firmware Revision'),
                  const Text('Software Revision'),
                  const Text('Transformer Size'),
                  const Text('Cell Model'),
                  const Text('CH Module ID'),
                  const Text('CH Module SW Version'),
                  const Text('CH Module HW Version'),
                ],
              ),
            ),
          ],
        ));
  }
}
