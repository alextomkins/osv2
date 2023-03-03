import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/dev_settings.dart';
import 'package:osv2/main.dart';
import 'package:intl/intl.dart';
import 'package:osv2/uuid_constants.dart';

import 'change_timer.dart';

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
  final today = DateTime.now();

  Future<void> _initData() async {
    rtcData = widget.rtcData;
    timersData = widget.timersData;
    timer1Start = DateTime(today.year, today.month, today.day,
        widget.timersData![0], widget.timersData![1]);
    timer1Duration = Duration(
        minutes: (widget.timersData![2] << 8) | (widget.timersData![3]));
    timer1End = timer1Start.add(timer1Duration);
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
      body:
          // StreamBuilder<Object>(
          // stream: rtcSubscriptionStream,
          // builder: (rtcContext, rtcSnapshot) {
          //   return SettingsList(sections: [
          //     SettingsSection(
          //       title: const Text('Date & Time'),
          //       tiles: [
          //         SettingsTile(
          //           title: const Text('Change Clock Time'),
          //           leading: const Icon(Icons.access_time),
          //           description: const Text('Add time in here later'),
          //           onPressed: (context) => Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => DevSettings(
          //                 device: widget.device,
          //                 flutterReactiveBle: widget.flutterReactiveBle,
          //                 connection: widget.connection,
          //                 modelNumberData: modelNumberData,
          //                 cpuDeviceInfoData: cpuDeviceInfoData,
          //                 manufacturerNameData: manufacturerNameData,
          //                 serielNumberData: serielNumberData,
          //               ),
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //     SettingsSection(
          //       title: const Text('Developer'),
          //       tiles: [
          //         SettingsTile.navigation(
          //           title: const Text('Developer Settings'),
          //           leading: const Icon(Icons.developer_mode),
          //           description: const Text(
          //               'Edit device settings, get developer info'),
          //           onPressed: (context) => Navigator.push(
          //             context,
          //             MaterialPageRoute(
          //               builder: (context) => DevSettings(
          //                 device: widget.device,
          //                 flutterReactiveBle: widget.flutterReactiveBle,
          //                 connection: widget.connection,
          //                 modelNumberData: modelNumberData,
          //                 cpuDeviceInfoData: cpuDeviceInfoData,
          //                 manufacturerNameData: manufacturerNameData,
          //                 serielNumberData: serielNumberData,
          //               ),
          //             ),
          //           ),
          //         )
          //       ],
          //     ),
          //   ]);
          // })

          Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                StreamBuilder<List<int>>(
                  stream: rtcSubscriptionStream,
                  builder: (rtcContext, rtcSnapshot) {
                    if (rtcSnapshot.hasData) {
                      rtcData = rtcSnapshot.data;
                    }
                    String rtcMonth = monthString[rtcData![5] - 1];
                    int rtcDay = rtcData![4];
                    String rtcDayOfWeek = dayOfWeekString[rtcData![3]];
                    int rtc24Hour = rtcData![2];
                    int rtc12Hour = rtc24Hour;
                    String rtcAmPm = 'am';
                    int rtcMinutes = rtcData![1];
                    if (rtc24Hour == 0) {
                      rtc12Hour = 12;
                      rtcAmPm = 'am';
                    } else if (rtc24Hour < 13) {
                      rtc12Hour = rtc24Hour;
                      rtcAmPm = 'am';
                      if (rtc12Hour == 12) {
                        rtcAmPm = 'pm';
                      }
                    } else {
                      rtc12Hour = rtc24Hour - 12;
                      rtcAmPm = 'pm';
                    }
                    // DateTime rtcDateTime = DateTime(rtcData![6] + 2000,
                    //     rtcData![5], rtcData![4], rtcData![2], rtcData![1]);

                    return Column(
                      children: [
                        TextButton(
                          onPressed: () async {
                            TimeOfDay? selectedTime = await showTimePicker(
                              initialTime: TimeOfDay.now(),
                              context: context,
                            );
                            if (selectedTime != null) {
                              final commandCharacteristic =
                                  QualifiedCharacteristic(
                                      serviceId: cpuModuleServiceUuid,
                                      characteristicId:
                                          commandCharacteristicUuid,
                                      deviceId: widget.device.id);
                              final commandResponse = await widget
                                  .flutterReactiveBle
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
                          },
                          child: Text(
                            //'Time\n${DateFormat('hh:mm').format(rtcDateTime)}${DateFormat('a').format(rtcDateTime).toLowerCase()}'
                            'test',
                            style: const TextStyle(
                                fontSize: 30.0,
                                color: Color.fromRGBO(53, 62, 71, 1)),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            DateTime? selectedDate = await showDatePicker(
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                              context: context,
                            );
                            if (selectedDate != null) {
                              final commandCharacteristic =
                                  QualifiedCharacteristic(
                                      serviceId: cpuModuleServiceUuid,
                                      characteristicId:
                                          commandCharacteristicUuid,
                                      deviceId: widget.device.id);
                              final commandResponse = await widget
                                  .flutterReactiveBle
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
                          },
                          child: Text(
                            //'Date\n${DateFormat('dd MMMM y').format(rtcDateTime)}'
                            'test',
                            style: const TextStyle(
                                fontSize: 30.0,
                                color: Color.fromRGBO(53, 62, 71, 1)),
                          ),
                        )
                      ],
                    );
                  },
                ),
                TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChangeTimer(
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
                        timer1Start = DateTime(today.year, today.month,
                            today.day, timersData![0], timersData![1]);
                        timer1Duration = Duration(
                            minutes: (timersData![2] << 8) | (timersData![3]));
                        timer1End = timer1Start.add(timer1Duration);
                        setState(() {});
                      });
                    },
                    child: Text(
                        'Timer 1\nStart: ${DateFormat('hh:mm').format(timer1Start)}${DateFormat('a').format(timer1Start).toLowerCase()}\tStop: ${DateFormat('hh:mm').format(timer1End)}${DateFormat('a').format(timer1End).toLowerCase()}')),
                TextButton(
                    onPressed: () => {
                          widget.connection!.cancel(),
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const MyHomePage(
                                title: 'Ozone Swim',
                              ),
                            ),
                            (Route<dynamic> route) => false,
                          )
                        },
                    child: const Text('Disconnect')),
                TextButton(
                    onPressed: () async => {
                          manufacturerNameData = await widget.flutterReactiveBle
                              .readCharacteristic(QualifiedCharacteristic(
                                  characteristicId:
                                      manufacturerNameCharacteristicUuid,
                                  serviceId: deviceInformationServiceUuid,
                                  deviceId: widget.device.id)),
                          modelNumberData = await widget.flutterReactiveBle
                              .readCharacteristic(QualifiedCharacteristic(
                                  characteristicId:
                                      modelNumberCharacteristicUuid,
                                  serviceId: deviceInformationServiceUuid,
                                  deviceId: widget.device.id)),
                          serielNumberData = await widget.flutterReactiveBle
                              .readCharacteristic(QualifiedCharacteristic(
                                  characteristicId:
                                      serielNumberCharacteristicUuid,
                                  serviceId: deviceInformationServiceUuid,
                                  deviceId: widget.device.id)),
                          hardwareRevisionData = await widget.flutterReactiveBle
                              .readCharacteristic(QualifiedCharacteristic(
                                  characteristicId:
                                      hardwareRevisionCharacteristicUuid,
                                  serviceId: deviceInformationServiceUuid,
                                  deviceId: widget.device.id)),
                          firmwareRevisionData = await widget.flutterReactiveBle
                              .readCharacteristic(QualifiedCharacteristic(
                                  characteristicId:
                                      firmwareRevisionCharacteristicUuid,
                                  serviceId: deviceInformationServiceUuid,
                                  deviceId: widget.device.id)),
                          cpuDeviceInfoData = await widget.flutterReactiveBle
                              .readCharacteristic(QualifiedCharacteristic(
                                  characteristicId:
                                      cpuDeviceInfoCharacteristicUuid,
                                  serviceId: cpuModuleServiceUuid,
                                  deviceId: widget.device.id)),
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DevSettings(
                                device: widget.device,
                                flutterReactiveBle: widget.flutterReactiveBle,
                                connection: widget.connection,
                                manufacturerNameData: manufacturerNameData,
                                modelNumberData: modelNumberData,
                                serielNumberData: serielNumberData,
                                cpuDeviceInfoData: cpuDeviceInfoData,
                              ),
                            ),
                          )
                        },
                    child: const Text('Developer')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
