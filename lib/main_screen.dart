import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:intl/intl.dart';
import 'package:osv2/settings.dart';
import 'package:osv2/settings_v2.dart';
import 'package:osv2/uuid_constants.dart';
import 'custom_dialogs.dart';
import 'my_flutter_app_icons.dart';

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

class MainScreen extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? runModeData;
  final List<int>? rtcData;
  final List<int>? cpuStatusData;
  final List<int>? timersData;

  const MainScreen(
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
  State<MainScreen> createState() => _MainScreenState();
}

List<bool> isSelected = [false, false, false];

Color ozoneColor = const Color.fromRGBO(53, 62, 71, 1);
Color chlorineColor = const Color.fromRGBO(53, 62, 71, 1);
Color probeColor = const Color.fromRGBO(53, 62, 71, 1);

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class _MainScreenState extends State<MainScreen> {
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
  int runMode = 0;
  DateTime timer1Start = DateTime.now();
  DateTime timer1End = DateTime.now();
  Duration timer1Duration = const Duration(minutes: 0);
  final today = DateTime.now();
  double timer1Progress = 0.0;
  Timer? timer;
  bool inTimer = false;

  void _initData() {
    cpuStatusData = widget.cpuStatusData;
    rtcData = widget.rtcData;
    runModeData = widget.runModeData;
    timersData = widget.timersData;
    timer1Start = DateTime(today.year, today.month, today.day,
        widget.timersData![0], widget.timersData![1]);
    timer1Duration = Duration(
        minutes: (widget.timersData![2] << 8) | (widget.timersData![3]));
    timer1End = timer1Start.add(timer1Duration);
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
          "Ozone Swim",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings_v2(
                      device: widget.device,
                      flutterReactiveBle: widget.flutterReactiveBle,
                      connection: widget.connection,
                      cpuStatusData: cpuStatusData,
                      rtcData: rtcData,
                      runModeData: runModeData,
                      timersData: timersData,
                    ),
                  ),
                ).then((_) async {
                  timersData = await widget.flutterReactiveBle
                      .readCharacteristic(QualifiedCharacteristic(
                          characteristicId: timersCharacteristicUuid,
                          serviceId: cpuModuleServiceUuid,
                          deviceId: widget.device.id));
                  timer1Start = DateTime(today.year, today.month, today.day,
                      timersData![0], timersData![1]);
                  timer1Duration = Duration(
                      minutes: (timersData![2] << 8) | (timersData![3]));
                  timer1End = timer1Start.add(timer1Duration);
                  setState(() {});
                });
              },
              icon: const Icon(Icons.settings)),
        ],
      ),
      body: StreamBuilder<List<int>>(
          stream: runModeSubscriptionStream,
          builder: (runModecontext, runModesnapshot) {
            if (runModesnapshot.hasData) {
              runModeData = runModesnapshot.data;
            }
            runMode = runModeData![0] & 0xF;
            if (runMode == 0) {
              isSelected = [true, false, false];
            } else if (runMode == 1) {
              isSelected = [false, true, false];
            } else if (runMode == 2) {
              isSelected = [false, false, true];
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                StreamBuilder<List<int>>(
                    stream: cpuStatusSubscriptionStream,
                    builder: (cpuStatusContext, cpuStatusSnapshot) {
                      if (cpuStatusSnapshot.hasData) {
                        cpuStatusData = cpuStatusSnapshot.data;
                      }
                      ozoneColor = checkBit(cpuStatusData![0], 3)
                          ? const Color.fromRGBO(88, 201, 223, 1)
                          : const Color.fromRGBO(53, 62, 71, 1);
                      chlorineColor = checkBit(cpuStatusData![0], 2)
                          ? const Color.fromRGBO(88, 201, 223, 1)
                          : const Color.fromRGBO(53, 62, 71, 1);
                      probeColor = checkBit(cpuStatusData![1], 1)
                          ? const Color.fromRGBO(88, 201, 223, 1)
                          : const Color.fromRGBO(53, 62, 71, 1);

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: IconButton(
                                iconSize: 40.0,
                                onPressed: () async {
                                  List<int> ozValuesData = await widget
                                      .flutterReactiveBle
                                      .readCharacteristic(
                                          QualifiedCharacteristic(
                                              characteristicId:
                                                  ozValuesCharacteristicUuid,
                                              serviceId:
                                                  modbusDevicesServiceUuid,
                                              deviceId: widget.device.id));
                                  int setpoint = ozValuesData[0];
                                  int averageCurrent = (ozValuesData[1] << 8) |
                                      (ozValuesData[2]);
                                  int temperature = (ozValuesData[3] << 8) |
                                      (ozValuesData[4]);
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return OzoneInfoDialog(
                                          setpoint: setpoint,
                                          averageCurrent: averageCurrent,
                                          temperature: temperature,
                                          device: widget.device,
                                          flutterReactiveBle:
                                              widget.flutterReactiveBle);
                                    },
                                  );
                                },
                                icon: Icon(
                                  CustomIcons.icono3v2,
                                  color: ozoneColor,
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                  padding: const EdgeInsets.only(left: 15.0),
                                  child: IconButton(
                                      iconSize: 40.0,
                                      onPressed: () async {
                                        List<int> chValuesData = await widget
                                            .flutterReactiveBle
                                            .readCharacteristic(
                                                QualifiedCharacteristic(
                                                    characteristicId:
                                                        chValuesCharacteristicUuid,
                                                    serviceId:
                                                        modbusDevicesServiceUuid,
                                                    deviceId:
                                                        widget.device.id));
                                        int averageCurrent =
                                            (chValuesData[0] << 8) |
                                                (chValuesData[1]);
                                        int maxCurrent =
                                            (chValuesData[2] << 8) |
                                                (chValuesData[3]);
                                        int setpoint = chValuesData[4];
                                        int period = (chValuesData[5] << 8) |
                                            (chValuesData[6]);
                                        int temperature =
                                            (chValuesData[7] << 8) |
                                                (chValuesData[8]);
                                        ChlorineInfoDialog(
                                            setpoint: setpoint,
                                            averageCurrent: averageCurrent,
                                            temperature: temperature,
                                            device: widget.device,
                                            flutterReactiveBle:
                                                widget.flutterReactiveBle,
                                            maxCurrent: maxCurrent,
                                            period: period);
                                      },
                                      icon: Icon(
                                        CustomIcons.iconcl2,
                                        color: chlorineColor,
                                      ))),
                              Padding(
                                padding: const EdgeInsets.only(right: 15.0),
                                child: IconButton(
                                    iconSize: 40.0,
                                    onPressed: () async {
                                      List<int> prValuesData = await widget
                                          .flutterReactiveBle
                                          .readCharacteristic(
                                              QualifiedCharacteristic(
                                                  characteristicId:
                                                      prValuesCharacteristicUuid,
                                                  serviceId:
                                                      modbusDevicesServiceUuid,
                                                  deviceId: widget.device.id));
                                      int flowRate = (prValuesData[0] << 8) |
                                          (prValuesData[1]);
                                      int waterTemperature =
                                          (prValuesData[2] << 8) |
                                              (prValuesData[3]);
                                      int phValue = (prValuesData[4] << 8) |
                                          (prValuesData[5]);
                                      int orpValue = (prValuesData[6] << 8) |
                                          (prValuesData[7]);
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ProbesInfoDialog(
                                              device: widget.device,
                                              flutterReactiveBle:
                                                  widget.flutterReactiveBle,
                                              flowRate: flowRate,
                                              waterTemperature:
                                                  waterTemperature,
                                              phValue: phValue,
                                              orpValue: orpValue);
                                        },
                                      );
                                    },
                                    icon: Icon(
                                      Icons.remove_red_eye,
                                      color: probeColor,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      );
                    }),
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

                    return Column(
                      children: [
                        Stack(
                          children: [
                            const Center(
                              child: SizedBox(
                                width: 300,
                                height: 300,
                                child: CircularProgressIndicator(
                                  strokeWidth: 6.0,
                                  color: Color.fromRGBO(88, 201, 223, 1),
                                ),
                              ),
                            ),
                            Center(
                                child: Padding(
                                    padding: const EdgeInsets.all(70.0),
                                    child: Column(children: [
                                      Column(
                                        children: [
                                          Text(
                                            rtcDayOfWeek,
                                            style: const TextStyle(
                                                fontSize: 30.0,
                                                color: Color.fromRGBO(
                                                    53, 62, 71, 1)),
                                          ),
                                          Text(
                                            '$rtc12Hour:${rtcMinutes.toString().padLeft(2, '0')}$rtcAmPm',
                                            style: const TextStyle(
                                                fontSize: 60.0,
                                                fontWeight: FontWeight.bold,
                                                color: Color.fromRGBO(
                                                    53, 62, 71, 1)),
                                          ),
                                          Text(
                                            '$rtcDay $rtcMonth',
                                            style: const TextStyle(
                                                fontSize: 30.0,
                                                color: Color.fromRGBO(
                                                    53, 62, 71, 1)),
                                          ),
                                        ],
                                      )
                                    ])))
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Opacity(
                            opacity: (runMode == 1) ? 1.0 : 0.5,
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 40.0),
                                      child: Column(
                                        children: [
                                          const Text('Start Time',
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Color.fromRGBO(
                                                      53, 62, 71, 1))),
                                          Text(
                                              '${DateFormat('hh:mm').format(timer1Start)}${DateFormat('a').format(timer1Start).toLowerCase()}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  color: Color.fromRGBO(
                                                      88, 201, 223, 1))),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(right: 40.0),
                                      child: Column(
                                        children: [
                                          const Text('Stop Time',
                                              style: TextStyle(
                                                  fontSize: 20.0,
                                                  color: Color.fromRGBO(
                                                      53, 62, 71, 1))),
                                          Text(
                                              '${DateFormat('hh:mm').format(timer1End)}${DateFormat('a').format(timer1End).toLowerCase()}',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20.0,
                                                  color: Color.fromRGBO(
                                                      88, 201, 223, 1))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: SizedBox(
                                      width: 250.0,
                                      height: 35.0,
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(20.0)),
                                        child: LinearProgressIndicator(
                                          value: timer1Progress,
                                          backgroundColor: const Color.fromRGBO(
                                              53, 62, 71, 200),
                                          color: const Color.fromRGBO(
                                              88, 201, 223, 1),
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 80.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ToggleButtons(
                        constraints: const BoxConstraints.expand(width: 100),
                        borderRadius: BorderRadius.circular(10.0),
                        borderColor: const Color.fromRGBO(53, 62, 71, 1),
                        isSelected: isSelected,
                        onPressed: (int buttonSelected) async {
                          final commandCharacteristic = QualifiedCharacteristic(
                              serviceId: cpuModuleServiceUuid,
                              characteristicId: commandCharacteristicUuid,
                              deviceId: widget.device.id);
                          final commandResponse = await widget
                              .flutterReactiveBle
                              .readCharacteristic(commandCharacteristic);
                          if (commandResponse[0] == 0) {
                            await widget.flutterReactiveBle
                                .writeCharacteristicWithResponse(
                                    commandCharacteristic,
                                    value: [(buttonSelected + 100)]);
                          }
                          // await Future.delayed(const Duration(seconds: 1));
                        },
                        fillColor: const Color.fromRGBO(53, 62, 71, 1),
                        selectedBorderColor:
                            const Color.fromRGBO(53, 62, 71, 1),
                        color: const Color.fromRGBO(53, 62, 71, 1),
                        selectedColor: Colors.white,
                        children: const <Widget>[
                          Text(
                            "Off",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "Auto",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "On",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
