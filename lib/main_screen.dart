import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/chlorinator_screen.dart';
import 'package:osv2/home_screen.dart';
import 'package:osv2/ozone_screen.dart';
import 'package:osv2/probes_screen.dart';
import 'package:osv2/settings.dart';
import 'package:osv2/uuid_constants.dart';
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
  final List<int> runModeData;
  final List<int> rtcData;
  final List<int> cpuStatusData;
  final List<int> timersData;

  const MainScreen(
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
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  StreamController cpuStatusController = StreamController();
  StreamController rtcController = StreamController();
  StreamController runModeController = StreamController();
  StreamController timersController = StreamController();
  List<int> runModeData = [0, 0];
  List<int> rtcData = [0, 0, 0, 0, 0, 1, 0];
  List<int> cpuStatusData = [0, 0];
  List<int> timersData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
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
  List<int> chStatusData = [];
  int averageCurrent = 0;
  int maxCurrent = 0;
  int setPoint = 0;
  int period = 0;
  double temperature = 0;
  String rtcMonth = '';
  int rtcDay = 0;
  String rtcDayOfWeek = '';
  int rtc24Hour = 0;
  int rtc12Hour = 0;
  String rtcAmPm = '';
  int rtcMinutes = 0;

  void _initData() {
    cpuStatusData = widget.cpuStatusData;
    rtcData = widget.rtcData;
    rtcMonth = monthString[rtcData[5] - 1];
    rtcDay = rtcData[4];
    rtcDayOfWeek = dayOfWeekString[rtcData[3]];
    rtc24Hour = rtcData[2];
    rtc12Hour = rtc24Hour;
    rtcAmPm = 'am';
    rtcMinutes = rtcData[1];
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
    runModeData = widget.runModeData;
    timersData = widget.timersData;
    timer1Start24Hour = timersData[0];
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
    timer1StartMinutes = timersData[1];
    timer1DurationTotal = (timersData[2] << 8) | (timersData[3]);
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
    rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
    timer1StartTotalMinutes = timer1Start24Hour * 60 + timer1StartMinutes;
    int totalTimeMinutes;
    int elapsedTimeMinutes;
    if (timer1EndTotal > timer1StartTotalMinutes) {
      totalTimeMinutes = timer1EndTotal - timer1StartTotalMinutes;
      if (rtcTotalMinutes < timer1StartTotalMinutes) {
        elapsedTimeMinutes = 0;
      } else if (rtcTotalMinutes < timer1EndTotal) {
        elapsedTimeMinutes = rtcTotalMinutes - timer1StartTotalMinutes;
      } else {
        elapsedTimeMinutes = totalTimeMinutes;
      }
    } else {
      totalTimeMinutes = 1440 - (timer1StartTotalMinutes - timer1EndTotal);
      if (rtcTotalMinutes > timer1StartTotalMinutes) {
        elapsedTimeMinutes = rtcTotalMinutes - timer1StartTotalMinutes;
      } else if (rtcTotalMinutes < timer1EndTotal) {
        elapsedTimeMinutes =
            totalTimeMinutes - (timer1EndTotal - timer1StartTotalMinutes);
      } else {
        elapsedTimeMinutes = 0;
      }
    }
    timer1Progress = elapsedTimeMinutes / totalTimeMinutes;
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
    if (timersController.hasListener == false) {
      timersController.addStream(widget.flutterReactiveBle
          .subscribeToCharacteristic(QualifiedCharacteristic(
              characteristicId: timersCharacteristicUuid,
              serviceId: cpuModuleServiceUuid,
              deviceId: widget.device.id)));
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _initData();
    _initStream();

    Timer.periodic(const Duration(seconds: 1), (timer) async {
      List<int> chValuesData = await widget.flutterReactiveBle
          .readCharacteristic(QualifiedCharacteristic(
              characteristicId: chValuesCharacteristicUuid,
              serviceId: modbusDevicesServiceUuid,
              deviceId: widget.device.id));
      chStatusData = await widget.flutterReactiveBle.readCharacteristic(
          QualifiedCharacteristic(
              characteristicId: chStatusCharacteristicUuid,
              serviceId: modbusDevicesServiceUuid,
              deviceId: widget.device.id));
      averageCurrent = (chValuesData[0] << 8) | (chValuesData[1]);
      maxCurrent = (chValuesData[2] << 8) | (chValuesData[3]);
      setPoint = chValuesData[4];
      period = (chValuesData[5] << 8) | (chValuesData[6]);
      temperature =
          ((chValuesData[7] << 8) | (chValuesData[8])).toDouble() / 10;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
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
                  );
                },
                icon: const Icon(Icons.settings)),
          ],
          bottom: const TabBar(
            tabs: <Widget>[
              Tab(
                icon: Icon(Icons.home),
              ),
              Tab(
                icon: Icon(CustomIcons.iconcl2),
              ),
              Tab(
                icon: Icon(CustomIcons.icono3v2),
              ),
              Tab(
                icon: Icon(Icons.remove_red_eye),
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            StreamBuilder(
              stream: runModeController.stream,
              builder: (context, runModeSnapshot) {
                if (runModeSnapshot.hasData) {
                  runModeData = runModeSnapshot.data;
                }
                runMode = runModeData[0] & 0xF;
                return StreamBuilder(
                  stream: rtcController.stream,
                  builder: (BuildContext context,
                      AsyncSnapshot<dynamic> rtcSnapshot) {
                    if (rtcSnapshot.hasData) {
                      rtcData = rtcSnapshot.data;
                    }
                    String rtcMonth = monthString[rtcData[5] - 1];
                    int rtcDay = rtcData[4];
                    String rtcDayOfWeek = dayOfWeekString[rtcData[3]];
                    int rtc24Hour = rtcData[2];
                    int rtc12Hour = rtc24Hour;
                    String rtcAmPm = 'am';
                    int rtcMinutes = rtcData[1];
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
                    return StreamBuilder(
                      stream: timersController.stream,
                      builder: (context, timersSnapshot) {
                        if (timersSnapshot.hasData) {
                          timersData = timersSnapshot.data;
                        }
                        timer1Start24Hour = timersData[0];
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
                        timer1StartMinutes = timersData[1];
                        timer1DurationTotal =
                            (timersData[2] << 8) | (timersData[3]);
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
                        rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
                        timer1StartTotalMinutes =
                            timer1Start24Hour * 60 + timer1StartMinutes;
                        int totalTimeMinutes;
                        int elapsedTimeMinutes;
                        if (timer1EndTotal > timer1StartTotalMinutes) {
                          totalTimeMinutes =
                              timer1EndTotal - timer1StartTotalMinutes;
                          if (rtcTotalMinutes < timer1StartTotalMinutes) {
                            elapsedTimeMinutes = 0;
                          } else if (rtcTotalMinutes < timer1EndTotal) {
                            elapsedTimeMinutes =
                                rtcTotalMinutes - timer1StartTotalMinutes;
                          } else {
                            elapsedTimeMinutes = totalTimeMinutes;
                          }
                        } else {
                          totalTimeMinutes =
                              1440 - (timer1StartTotalMinutes - timer1EndTotal);
                          if (rtcTotalMinutes > timer1StartTotalMinutes) {
                            elapsedTimeMinutes =
                                rtcTotalMinutes - timer1StartTotalMinutes;
                          } else if (rtcTotalMinutes < timer1EndTotal) {
                            //print(totalTimeMinutes);
                            //print(timer1EndTotal);
                            //print(timer1StartTotalMinutes);
                            elapsedTimeMinutes = totalTimeMinutes -
                                (timer1EndTotal - rtcTotalMinutes);
                          } else {
                            elapsedTimeMinutes = 0;
                          }
                        }
                        timer1Progress = elapsedTimeMinutes / totalTimeMinutes;
                        return HomeScreen(
                          device: widget.device,
                          flutterReactiveBle: widget.flutterReactiveBle,
                          connection: widget.connection,
                          rtc12Hour: rtc12Hour,
                          rtcAmPm: rtcAmPm,
                          rtcDay: rtcDay,
                          rtcDayOfWeek: rtcDayOfWeek,
                          rtcMinutes: rtcMinutes,
                          rtcMonth: rtcMonth,
                          cpuStatusData: cpuStatusData,
                          runMode: runMode,
                          timer1End12Hour: timer1End12Hour,
                          timer1EndAmPm: timer1EndAmPm,
                          timer1EndMinutes: timer1EndMinutes,
                          timer1Progress: timer1Progress,
                          timer1Start12Hour: timer1Start12Hour,
                          timer1StartAmPm: timer1StartAmPm,
                          timer1StartMinutes: timer1StartMinutes,
                        );
                      },
                    );
                  },
                );
              },
            ),
            Chlorinator(
              chAverageCurrent: averageCurrent,
              chMaxCurrent: maxCurrent,
              chSetPoint: setPoint,
              chPeriod: period,
              chTemperature: temperature,
              chStatusData: chStatusData,
            ),
            const Ozone(),
            const Probes(),
          ],
        ),
      ),
    );
  }
}
