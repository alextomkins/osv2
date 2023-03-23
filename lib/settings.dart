import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/dev_settings.dart';
import 'package:osv2/main.dart';
import 'package:osv2/uuid_constants.dart';
import 'package:settings_ui/settings_ui.dart';
import 'change_timer2.dart';
import 'change_timer1.dart';

final List<String> monthString = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

final List<String> dayOfWeekString = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class Settings extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? runModeData;
  final List<int>? rtcData;
  final List<int>? cpuStatusData;
  final List<int>? timersData;

  const Settings(
      {Key? key,
      required this.device,
      required this.flutterReactiveBle,
      required this.connection,
      this.runModeData,
      this.rtcData,
      this.cpuStatusData,
      this.timersData})
      : super(key: key);

  @override
  State<Settings> createState() => _SettingsState();
}

List<String> dayString = [
  "Sunday",
  "Monday",
  "Tuesday",
  "Wednesday",
  "Thursday",
  "Friday",
  "Saturday"
];

Color ozoneColor = const Color.fromRGBO(53, 62, 71, 1);
Color chlorineColor = const Color.fromRGBO(53, 62, 71, 1);
Color probeColor = const Color.fromRGBO(53, 62, 71, 1);

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class _SettingsState extends State<Settings> {
  Stream<List<int>>? cpuStatusSubscriptionStream;
  Stream<List<int>>? rtcSubscriptionStream;
  Stream<List<int>>? runModeSubscriptionStream;
  List<int>? runModeData = [0, 0];
  List<int>? rtcData = [0, 0, 0, 0, 0, 1, 0];
  List<int>? cpuStatusData = [0, 0];
  List<int>? timersData = [
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0
  ];
  List<int>? manufacturerNameData = [];
  List<int>? modelNumberData = [];
  List<int>? serielNumberData = [];
  List<int>? hardwareRevisionData = [];
  List<int>? firmwareRevisionData = [];
  List<int>? cpuDeviceInfoData = [];
  int runMode = 0;
  DateTime timer1Start = DateTime.now();
  DateTime timer1End = DateTime.now();
  Duration timer1Duration = const Duration(minutes: 0);
  DateTime timer2Start = DateTime.now();
  DateTime timer2End = DateTime.now();
  Duration timer2Duration = const Duration(minutes: 0);
  final today = DateTime.now();

  Future<void> _initData() async {
    rtcData = widget.rtcData;
    timersData = widget.timersData;
    setState(() {});
  }

  void _initStream() {
    cpuStatusSubscriptionStream = widget.flutterReactiveBle
        .subscribeToCharacteristic(QualifiedCharacteristic(
            characteristicId: cpuStatusCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
            deviceId: widget.device.id));
    rtcSubscriptionStream = widget.flutterReactiveBle.subscribeToCharacteristic(
        QualifiedCharacteristic(
            characteristicId: rtcCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
            deviceId: widget.device.id));
    runModeSubscriptionStream = widget.flutterReactiveBle
        .subscribeToCharacteristic(QualifiedCharacteristic(
            characteristicId: runModeCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text(
              'Date & Time',
              style: TextStyle(color: Color.fromRGBO(88, 201, 223, 1)),
            ),
            tiles: <SettingsTile>[
              SettingsTile(
                  leading: const Icon(Icons.access_time_filled),
                  title: const Text('Change Clock Time'),
                  description: const Text('Change the time of the clock'),
                  onPressed: (context) async {
                    TimeOfDay? selectedTime = await showTimePicker(
                      initialTime: TimeOfDay.now(),
                      context: context,
                    );
                    if (selectedTime != null) {
                      final commandCharacteristic = QualifiedCharacteristic(
                          serviceId: cpuModuleServiceUuid,
                          characteristicId: commandCharacteristicUuid,
                          deviceId: widget.device.id);
                      final commandResponse = await widget.flutterReactiveBle
                          .readCharacteristic(commandCharacteristic);
                      if (commandResponse[0] == 0) {
                        await widget.flutterReactiveBle
                            .writeCharacteristicWithResponse(
                                commandCharacteristic,
                                value: [
                              1,
                              selectedTime.hour,
                              selectedTime.minute,
                              0
                            ]);
                      }
                    }
                  }),
              SettingsTile(
                  leading: const Icon(Icons.date_range),
                  title: const Text('Change Date'),
                  description: const Text('Change the date'),
                  onPressed: (context) async {
                    DateTime? selectedDate = await showDatePicker(
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                      context: context,
                    );
                    if (selectedDate != null) {
                      final commandCharacteristic = QualifiedCharacteristic(
                          serviceId: cpuModuleServiceUuid,
                          characteristicId: commandCharacteristicUuid,
                          deviceId: widget.device.id);
                      final commandResponse = await widget.flutterReactiveBle
                          .readCharacteristic(commandCharacteristic);
                      if (commandResponse[0] == 0) {
                        await widget.flutterReactiveBle
                            .writeCharacteristicWithResponse(
                                commandCharacteristic,
                                value: [
                              2,
                              selectedDate.day,
                              selectedDate.month,
                              selectedDate.year - 2000,
                            ]);
                      }
                    }
                  }),
            ],
          ),
          SettingsSection(
            title: const Text(
              'Timers',
              style: TextStyle(color: Color.fromRGBO(88, 201, 223, 1)),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: const Icon(Icons.timer),
                  title: const Text('Set Timer 1'),
                  description:
                      const Text('Change start time and duration of Timer 1'),
                  onPressed: (context) async {
                    timersData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId: timersCharacteristicUuid,
                            serviceId: cpuModuleServiceUuid,
                            deviceId: widget.device.id));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeTimer1(
                          device: widget.device,
                          flutterReactiveBle: widget.flutterReactiveBle,
                          connection: widget.connection,
                          timersData: timersData,
                        ),
                      ),
                    ).then((_) async {
                      timersData = await widget.flutterReactiveBle
                          .readCharacteristic(QualifiedCharacteristic(
                              characteristicId: timersCharacteristicUuid,
                              serviceId: cpuModuleServiceUuid,
                              deviceId: widget.device.id));
                    });
                  }),

              ///
              SettingsTile.navigation(
                  leading: const Icon(Icons.timer),
                  title: const Text('Set Timer 2'),
                  description:
                      const Text('Change start time and duration of Timer 2'),
                  onPressed: (context) async {
                    timersData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId: timersCharacteristicUuid,
                            serviceId: cpuModuleServiceUuid,
                            deviceId: widget.device.id));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChangeTimer2(
                          device: widget.device,
                          flutterReactiveBle: widget.flutterReactiveBle,
                          connection: widget.connection,
                          timersData: timersData,
                        ),
                      ),
                    ).then((_) async {
                      timersData = await widget.flutterReactiveBle
                          .readCharacteristic(QualifiedCharacteristic(
                              characteristicId: timersCharacteristicUuid,
                              serviceId: cpuModuleServiceUuid,
                              deviceId: widget.device.id));
                    });
                  }),
            ],
          ),
          SettingsSection(
            title: const Text(
              'Disconnect',
              style: TextStyle(color: Color.fromRGBO(88, 201, 223, 1)),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: const Icon(Icons.bluetooth_disabled),
                  title: const Text('Disconnect from Bluetooth'),
                  onPressed: (context) async {
                    widget.connection!.cancel();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyHomePage(
                          title: 'Ozone Swim v2',
                        ),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }),
            ],
          ),
          SettingsSection(
            title: const Text(
              'Developer',
              style: TextStyle(color: Color.fromRGBO(88, 201, 223, 1)),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                  leading: const Icon(Icons.developer_mode),
                  title: const Text('Developer Settings'),
                  description: const Text(
                      'Edit device settings and see developer information'),
                  onPressed: (context) async {
                    manufacturerNameData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId:
                                manufacturerNameCharacteristicUuid,
                            serviceId: deviceInformationServiceUuid,
                            deviceId: widget.device.id));
                    modelNumberData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId: modelNumberCharacteristicUuid,
                            serviceId: deviceInformationServiceUuid,
                            deviceId: widget.device.id));
                    serielNumberData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId: serielNumberCharacteristicUuid,
                            serviceId: deviceInformationServiceUuid,
                            deviceId: widget.device.id));
                    cpuDeviceInfoData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId: cpuDeviceInfoCharacteristicUuid,
                            serviceId: cpuModuleServiceUuid,
                            deviceId: widget.device.id));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevSettings(
                            device: widget.device,
                            flutterReactiveBle: widget.flutterReactiveBle,
                            connection: widget.connection,
                            manufacturerNameData: manufacturerNameData,
                            modelNumberData: modelNumberData,
                            cpuDeviceInfoData: cpuDeviceInfoData,
                            serielNumberData: serielNumberData),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
