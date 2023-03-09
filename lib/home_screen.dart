import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/animations.dart';
import 'package:osv2/uuid_constants.dart';

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

class HomeScreen extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? runModeData;
  final List<int>? rtcData;
  final List<int>? cpuStatusData;
  final List<int>? timersData;

  const HomeScreen(
      {Key? key,
      required this.device,
      required this.flutterReactiveBle,
      required this.connection,
      required this.runModeData,
      required this.rtcData,
      required this.cpuStatusData,
      required this.timersData})
      : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

List<bool> isSelected = [false, false, false];

Color ozoneColor = const Color.fromRGBO(53, 62, 71, 1);
Color chlorineColor = const Color.fromRGBO(53, 62, 71, 1);
Color probeColor = const Color.fromRGBO(53, 62, 71, 1);

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class _HomeScreenState extends State<HomeScreen>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  Stream<dynamic>? cpuStatusSubscriptionStream;
  Stream<dynamic>? rtcSubscriptionStream;
  Stream<dynamic>? runModeSubscriptionStream;
  StreamController cpuStatusController = StreamController();
  StreamController rtcController = StreamController();
  StreamController runModeController = StreamController();
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
    timersData = widget.timersData;
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
    timer1DurationTotal = (timersData![2] << 8) | (timersData![3]);
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
    if (cpuStatusController.hasListener == false) {
      cpuStatusController.addStream(widget.flutterReactiveBle
          .subscribeToCharacteristic(QualifiedCharacteristic(
              characteristicId: cpuStatusCharacteristicUuid,
              serviceId: cpuModuleServiceUuid,
              deviceId: widget.device.id)));
    }
    if (rtcController.hasListener == false) {
      rtcController.addStream(widget.flutterReactiveBle
          .subscribeToCharacteristic(QualifiedCharacteristic(
              characteristicId: rtcCharacteristicUuid,
              serviceId: cpuModuleServiceUuid,
              deviceId: widget.device.id)));
    }
    if (runModeController.hasListener == false) {
      runModeController.addStream(widget.flutterReactiveBle
          .subscribeToCharacteristic(QualifiedCharacteristic(
              characteristicId: runModeCharacteristicUuid,
              serviceId: cpuModuleServiceUuid,
              deviceId: widget.device.id)));
    }

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
    super.build(context);
    return Scaffold(
      body: StreamBuilder<dynamic>(
          stream: runModeController.stream,
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
                StreamBuilder<dynamic>(
                  stream: rtcController.stream,
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                  height: 300,
                                  width: 300,
                                  child: checkBit(cpuStatusData![0], 6)
                                      ? const RunningAnimation()
                                      : const RunningAnimation()),
                              SizedBox(
                                height: 300,
                                width: 300,
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
                                            backgroundColor:
                                                const Color.fromRGBO(
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
                      ),
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
