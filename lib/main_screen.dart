import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/settings.dart';
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

class _MainScreenState extends State<MainScreen>
    with SingleTickerProviderStateMixin {
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
  double timer1Progress = 0.0;
  Timer? timer;
  int timer1StartHour = 0;
  int timer1Start24Hour = 0;
  int timer1Start12Hour = 0;
  String timer1StartAmPm = '';
  int timer1StartMinutes = 0;
  int timer1DurationTotal = 0;
  int timer1DurationHour = 0;
  int timer1DurationMinutes = 0;
  double runTime = 0.0;
  int timer1EndTotal = 0;
  int timer1End24Hour = 0;
  int timer1End12Hour = 0;
  String timer1EndAmPm = '';
  int timer1EndMinutes = 0;
  int timer1ElapsedMinutes = 0;
  int rtcTotalMinutes = 0;
  int timer1StartTotalMinutes = 0;

  void _initData() {
    cpuStatusData = widget.cpuStatusData;
    rtcData = widget.rtcData;
    runModeData = widget.runModeData;
    timer1Start24Hour = widget.timersData![0];
    if (timer1Start24Hour == 0) {
      timer1Start12Hour = 12;
      timer1StartAmPm = 'am';
    } else if (timer1Start24Hour < 13) {
      timer1Start12Hour = timer1Start24Hour;
      timer1StartAmPm = 'am';
      if (timer1Start12Hour == 12) {
        timer1StartAmPm = 'pm';
      }
    } else {
      timer1Start12Hour = timer1Start24Hour - 12;
      timer1StartAmPm = 'pm';
    }
    timer1StartMinutes = widget.timersData![1];
    timer1DurationTotal =
        (widget.timersData![2] << 8) | (widget.timersData![3]);
    timer1DurationHour = (timer1DurationTotal / 60).floor();
    timer1DurationMinutes = timer1DurationTotal % 60;
    runTime = timer1DurationTotal.toDouble();
    timer1EndTotal =
        timer1Start24Hour * 60 + timer1StartMinutes + timer1DurationTotal;
    if (timer1EndTotal > 1440) {
      timer1EndTotal -= 1440;
    }
    timer1End24Hour = (timer1EndTotal / 60).floor();
    if (timer1End24Hour == 0) {
      timer1End12Hour = 12;
      timer1EndAmPm = 'am';
    } else if (timer1End24Hour < 13) {
      timer1End12Hour = timer1End24Hour;
      timer1EndAmPm = 'am';
      if (timer1End12Hour == 12) {
        timer1EndAmPm = 'pm';
      }
    } else {
      timer1End12Hour = timer1End24Hour - 12;
      timer1EndAmPm = 'pm';
    }
    timer1EndMinutes = timer1EndTotal % 60;
    rtcTotalMinutes = rtcData![1] + rtcData![2] * 60;
    timer1StartTotalMinutes = timer1Start24Hour * 60 + timer1StartMinutes;
    if (rtcTotalMinutes > timer1StartTotalMinutes) {
      timer1ElapsedMinutes = rtcTotalMinutes - timer1StartTotalMinutes;
    }
    if (timer1ElapsedMinutes < timer1DurationTotal) {
      timer1Progress = timer1ElapsedMinutes / timer1DurationTotal;
    }
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

  late AnimationController _animationController;
  late Animation _animation;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _animationController.repeat(reverse: true);
    _animation = Tween(begin: 2.0, end: 20.0).animate(_animationController)
      ..addListener(() {
        setState(() {});
      });
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
          "Ozone Swim v2",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Settings(
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
                  timer1Start24Hour = timersData![0];
                  if (timer1Start24Hour == 0) {
                    timer1Start12Hour = 12;
                    timer1StartAmPm = 'am';
                  } else if (timer1Start24Hour < 13) {
                    timer1Start12Hour = timer1Start24Hour;
                    timer1StartAmPm = 'am';
                    if (timer1Start12Hour == 12) {
                      timer1StartAmPm = 'pm';
                    }
                  } else {
                    timer1Start12Hour = timer1Start24Hour - 12;
                    timer1StartAmPm = 'pm';
                  }
                  timer1StartMinutes = timersData![1];
                  timer1DurationTotal =
                      (timersData![2] << 8) | (timersData![3]);
                  timer1DurationHour = (timer1DurationTotal / 60).floor();
                  timer1DurationMinutes = timer1DurationTotal % 60;
                  runTime = timer1DurationTotal.toDouble();
                  timer1EndTotal = timer1Start24Hour * 60 +
                      timer1StartMinutes +
                      timer1DurationTotal;
                  if (timer1EndTotal > 1440) {
                    timer1EndTotal -= 1440;
                  }
                  timer1End24Hour = (timer1EndTotal / 60).floor();
                  if (timer1End24Hour == 0) {
                    timer1End12Hour = 12;
                    timer1EndAmPm = 'am';
                  } else if (timer1End24Hour < 13) {
                    timer1End12Hour = timer1End24Hour;
                    timer1EndAmPm = 'am';
                    if (timer1End12Hour == 12) {
                      timer1EndAmPm = 'pm';
                    }
                  } else {
                    timer1End12Hour = timer1End24Hour - 12;
                    timer1EndAmPm = 'pm';
                  }
                  timer1EndMinutes = timer1EndTotal % 60;
                  rtcTotalMinutes = rtcData![1] + rtcData![2] * 60;
                  timer1StartTotalMinutes =
                      timer1Start24Hour * 60 + timer1StartMinutes;
                  if (rtcTotalMinutes > timer1StartTotalMinutes) {
                    timer1ElapsedMinutes =
                        rtcTotalMinutes - timer1StartTotalMinutes;
                  }
                  if (timer1ElapsedMinutes < timer1DurationTotal) {
                    timer1Progress = timer1ElapsedMinutes / timer1DurationTotal;
                  } else {
                    timer1Progress = 1.0;
                  }
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
                    rtcTotalMinutes = rtcMinutes + rtc24Hour * 60;
                    if (rtcTotalMinutes > timer1StartTotalMinutes) {
                      timer1ElapsedMinutes =
                          rtcTotalMinutes - timer1StartTotalMinutes;
                    }
                    if (timer1ElapsedMinutes < timer1DurationTotal) {
                      timer1Progress =
                          timer1ElapsedMinutes / timer1DurationTotal;
                    } else {
                      timer1Progress = 1.0;
                    }
                    return Column(
                      children: [
                        Container(
                          height: 320,
                          width: 400,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        const Color.fromRGBO(88, 201, 223, 1),
                                    blurRadius: _animation.value,
                                    spreadRadius: _animation.value)
                              ]),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                rtcDayOfWeek,
                                style: const TextStyle(
                                    fontSize: 30.0,
                                    color: Color.fromRGBO(53, 62, 71, 1)),
                              ),
                              Text(
                                '$rtc12Hour:${rtcMinutes.toString().padLeft(2, '0')}$rtcAmPm',
                                style: const TextStyle(
                                    fontSize: 60.0,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromRGBO(53, 62, 71, 1)),
                              ),
                              Text(
                                '$rtcDay $rtcMonth',
                                style: const TextStyle(
                                    fontSize: 30.0,
                                    color: Color.fromRGBO(53, 62, 71, 1)),
                              ),
                            ],
                          ),
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
                                              '$timer1Start12Hour:${timer1StartMinutes.toString().padLeft(2, '0')}$timer1StartAmPm',
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
                                              '$timer1End12Hour:${timer1EndMinutes.toString().padLeft(2, '0')}$timer1EndAmPm',
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
                    padding: const EdgeInsets.only(bottom: 60.0),
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
