import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/screens/modules/chlorinator_screen.dart';
import 'package:osv2/screens/home_screen.dart';
import 'package:osv2/screens/modules/ozone_screen.dart';
import 'package:osv2/screens/modules/probes_screen.dart';
import 'package:osv2/screens/settings/settings_screen.dart';
import 'package:osv2/util/uuid_constants.dart';
import '../assets/custom_icons.dart';

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

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

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
  StreamController runModeController = StreamController.broadcast();
  StreamController timersController = StreamController();
  List<int> runModeData = [0, 0];
  List<int> rtcData = [0, 0, 0, 0, 0, 1, 0];
  List<int> cpuStatusData = [0, 0];
  List<int> timersData = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
  int runMode = 0;
  int chRunMode = 0;
  int ozRunMode = 0;
  int prRunMode = 0;
  Timer? timer;

  ///
  double timer1Progress = 0.0;
  int timer1StartHour = 0;
  int timer1Start24Hour = 0;
  int timer1Start12Hour = 0;
  String timer1StartAmPm = '';
  int timer1StartMinutes = 0;
  int timer1DurationTotal = 0;
  int timer1DurationHour = 0;
  int timer1DurationMinutes = 0;
  double timer1RunTime = 0.0;
  int timer1EndTotal = 0;
  int timer1End24Hour = 0;
  int timer1End12Hour = 0;
  String timer1EndAmPm = '';
  int timer1EndMinutes = 0;
  int timer1ElapsedMinutes = 0;
  int rtcTotalMinutes = 0;
  int timer1StartTotalMinutes = 0;

  ///
  double timer2Progress = 0.0;
  int timer2StartHour = 0;
  int timer2Start24Hour = 0;
  int timer2Start12Hour = 0;
  String timer2StartAmPm = '';
  int timer2StartMinutes = 0;
  int timer2DurationTotal = 0;
  int timer2DurationHour = 0;
  int timer2DurationMinutes = 0;
  double timer2RunTime = 0.0;
  int timer2EndTotal = 0;
  int timer2End24Hour = 0;
  int timer2End12Hour = 0;
  String timer2EndAmPm = '';
  int timer2EndMinutes = 0;
  int timer2ElapsedMinutes = 0;
  int timer2StartTotalMinutes = 0;

  ///
  double timer3Progress = 0.0;
  int timer3StartHour = 0;
  int timer3Start24Hour = 0;
  int timer3Start12Hour = 0;
  String timer3StartAmPm = '';
  int timer3StartMinutes = 0;
  int timer3DurationTotal = 0;
  int timer3DurationHour = 0;
  int timer3DurationMinutes = 0;
  double timer3RunTime = 0.0;
  int timer3EndTotal = 0;
  int timer3End24Hour = 0;
  int timer3End12Hour = 0;
  String timer3EndAmPm = '';
  int timer3EndMinutes = 0;
  int timer3ElapsedMinutes = 0;
  int timer3StartTotalMinutes = 0;

  ///
  List<int> chStatusData = [];
  int chAverageCurrent = 0;
  int chMaxCurrent = 0;
  int chSetPoint = 0;
  int chPeriod = 0;
  double chTemperature = 0;

  ///
  List<int> ozStatusData = [];
  int ozAverageCurrent = 0;
  int ozSetPoint = 0;
  double ozTemperature = 0;

  ///
  List<int> prStatusData = [];
  int prWaterFlow = 0;
  double prTemperature = 0;
  int prPH = 0;
  int prOrp = 0;

  ///
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
    timer1RunTime = timer1DurationTotal.toDouble();
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

    ///
    timer2Start24Hour = timersData[6];
    if (timer2Start24Hour == 0) {
      timer2Start12Hour = 12;
      timer2StartAmPm = 'am';
    } else if (timer2Start24Hour < 13) {
      timer2Start12Hour = timer2Start24Hour;
      timer2StartAmPm = 'am';
      if (timer2Start12Hour == 12) {
        timer2StartAmPm = 'pm';
      }
    } else {
      timer2Start12Hour = timer2Start24Hour - 12;
      timer2StartAmPm = 'pm';
    }
    timer2StartMinutes = timersData[7];
    timer2DurationTotal = (timersData[8] << 8) | (timersData[9]);
    timer2DurationHour = (timer2DurationTotal / 60).floor();
    timer2DurationMinutes = timer2DurationTotal % 60;
    timer2RunTime = timer2DurationTotal.toDouble();
    timer2EndTotal =
        timer2Start24Hour * 60 + timer2StartMinutes + timer2DurationTotal;
    if (timer2EndTotal > 1440) {
      timer2EndTotal -= 1440;
    }
    timer2End24Hour = (timer2EndTotal / 60).floor();
    if (timer2End24Hour == 0) {
      timer2End12Hour = 12;
      timer2EndAmPm = 'am';
    } else if (timer2End24Hour < 13) {
      timer2End12Hour = timer2End24Hour;
      timer2EndAmPm = 'am';
      if (timer2End12Hour == 12) {
        timer2EndAmPm = 'pm';
      }
    } else {
      timer2End12Hour = timer2End24Hour - 12;
      timer2EndAmPm = 'pm';
    }
    timer2EndMinutes = timer2EndTotal % 60;
    rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
    timer2StartTotalMinutes = timer2Start24Hour * 60 + timer2StartMinutes;
    if (timer2EndTotal > timer2StartTotalMinutes) {
      totalTimeMinutes = timer2EndTotal - timer2StartTotalMinutes;
      if (rtcTotalMinutes < timer2StartTotalMinutes) {
        elapsedTimeMinutes = 0;
      } else if (rtcTotalMinutes < timer2EndTotal) {
        elapsedTimeMinutes = rtcTotalMinutes - timer2StartTotalMinutes;
      } else {
        elapsedTimeMinutes = totalTimeMinutes;
      }
    } else {
      totalTimeMinutes = 1440 - (timer2StartTotalMinutes - timer2EndTotal);
      if (rtcTotalMinutes > timer2StartTotalMinutes) {
        elapsedTimeMinutes = rtcTotalMinutes - timer2StartTotalMinutes;
      } else if (rtcTotalMinutes < timer2EndTotal) {
        elapsedTimeMinutes =
            totalTimeMinutes - (timer2EndTotal - timer2StartTotalMinutes);
      } else {
        elapsedTimeMinutes = 0;
      }
    }
    timer2Progress = elapsedTimeMinutes / totalTimeMinutes;

    ///
    timer3Start24Hour = timersData[12];
    if (timer3Start24Hour == 0) {
      timer3Start12Hour = 12;
      timer3StartAmPm = 'am';
    } else if (timer3Start24Hour < 13) {
      timer3Start12Hour = timer3Start24Hour;
      timer3StartAmPm = 'am';
      if (timer3Start12Hour == 12) {
        timer3StartAmPm = 'pm';
      }
    } else {
      timer3Start12Hour = timer3Start24Hour - 12;
      timer3StartAmPm = 'pm';
    }
    timer3StartMinutes = timersData[13];
    timer3DurationTotal = (timersData[14] << 8) | (timersData[15]);
    timer3DurationHour = (timer3DurationTotal / 60).floor();
    timer3DurationMinutes = timer3DurationTotal % 60;
    timer3RunTime = timer3DurationTotal.toDouble();
    timer3EndTotal =
        timer3Start24Hour * 60 + timer3StartMinutes + timer3DurationTotal;
    if (timer3EndTotal > 1440) {
      timer3EndTotal -= 1440;
    }
    timer3End24Hour = (timer3EndTotal / 60).floor();
    if (timer3End24Hour == 0) {
      timer3End12Hour = 12;
      timer3EndAmPm = 'am';
    } else if (timer3End24Hour < 13) {
      timer3End12Hour = timer3End24Hour;
      timer3EndAmPm = 'am';
      if (timer3End12Hour == 12) {
        timer3EndAmPm = 'pm';
      }
    } else {
      timer3End12Hour = timer3End24Hour - 12;
      timer3EndAmPm = 'pm';
    }
    timer3EndMinutes = timer3EndTotal % 60;
    rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
    timer3StartTotalMinutes = timer3Start24Hour * 60 + timer3StartMinutes;
    if (timer3EndTotal > timer3StartTotalMinutes) {
      totalTimeMinutes = timer3EndTotal - timer3StartTotalMinutes;
      if (rtcTotalMinutes < timer3StartTotalMinutes) {
        elapsedTimeMinutes = 0;
      } else if (rtcTotalMinutes < timer3EndTotal) {
        elapsedTimeMinutes = rtcTotalMinutes - timer3StartTotalMinutes;
      } else {
        elapsedTimeMinutes = totalTimeMinutes;
      }
    } else {
      totalTimeMinutes = 1440 - (timer3StartTotalMinutes - timer3EndTotal);
      if (rtcTotalMinutes > timer3StartTotalMinutes) {
        elapsedTimeMinutes = rtcTotalMinutes - timer3StartTotalMinutes;
      } else if (rtcTotalMinutes < timer3EndTotal) {
        elapsedTimeMinutes =
            totalTimeMinutes - (timer3EndTotal - timer3StartTotalMinutes);
      } else {
        elapsedTimeMinutes = 0;
      }
    }
    timer3Progress = elapsedTimeMinutes / totalTimeMinutes;

    ///
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
      chAverageCurrent = (chValuesData[0] << 8) | (chValuesData[1]);
      chMaxCurrent = (chValuesData[2] << 8) | (chValuesData[3]);
      chSetPoint = chValuesData[4];
      chPeriod = (chValuesData[5] << 8) | (chValuesData[6]);
      chTemperature =
          ((chValuesData[7] << 8) | (chValuesData[8])).toDouble() / 10;

      /// TODO: Use oz UUIDs when implimented
      List<int> ozValuesData = await widget.flutterReactiveBle
          .readCharacteristic(QualifiedCharacteristic(
              characteristicId: chValuesCharacteristicUuid,
              serviceId: modbusDevicesServiceUuid,
              deviceId: widget.device.id));
      ozStatusData = await widget.flutterReactiveBle.readCharacteristic(
          QualifiedCharacteristic(
              characteristicId: chStatusCharacteristicUuid,
              serviceId: modbusDevicesServiceUuid,
              deviceId: widget.device.id));
      ozAverageCurrent = (ozValuesData[1] << 8) | (ozValuesData[2]);
      ozSetPoint = ozValuesData[0];
      ozTemperature =
          ((ozValuesData[3] << 8) | (ozValuesData[4])).toDouble() / 10;

      /// TODO: Use pr UUIDs when implimented
      List<int> prValuesData = await widget.flutterReactiveBle
          .readCharacteristic(QualifiedCharacteristic(
              characteristicId: chValuesCharacteristicUuid,
              serviceId: modbusDevicesServiceUuid,
              deviceId: widget.device.id));
      prStatusData = await widget.flutterReactiveBle.readCharacteristic(
          QualifiedCharacteristic(
              characteristicId: chStatusCharacteristicUuid,
              serviceId: modbusDevicesServiceUuid,
              deviceId: widget.device.id));
      prWaterFlow = (prValuesData[0] << 8) | (prValuesData[1]);
      prTemperature =
          ((prValuesData[2] << 8) | (prValuesData[3])).toDouble() / 10;
      prPH = (prValuesData[4] << 8) | (prValuesData[5]);
      prOrp = (prValuesData[6] << 8) | (prValuesData[7]);
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(90.0),
          child: StreamBuilder(
              stream: cpuStatusController.stream,
              builder: (context, cpuStatusSnapshot) {
                if (cpuStatusSnapshot.hasData) {
                  cpuStatusData = cpuStatusSnapshot.data;
                }
                return AppBar(
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
                  bottom: TabBar(
                    tabs: <Widget>[
                      const Tab(
                        icon: Icon(Icons.home),
                      ),
                      Tab(
                        icon: checkBit(cpuStatusData[0], 2)
                            ? const Icon(CustomIcons.iconcl2)
                            : const Icon(
                                CustomIcons.iconcl2,
                                color: Colors.black26,
                              ),
                      ),
                      Tab(
                        icon: checkBit(cpuStatusData[0], 3)
                            ? const Icon(CustomIcons.icono3v2)
                            : const Icon(
                                CustomIcons.icono3v2,
                                color: Colors.black26,
                              ),
                      ),
                      Tab(
                        icon: checkBit(cpuStatusData[1], 1)
                            ? const Icon(Icons.remove_red_eye)
                            : const Icon(
                                Icons.remove_red_eye,
                                color: Colors.black26,
                              ),
                      ),
                    ],
                  ),
                );
              }),
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
                        timer1RunTime = timer1DurationTotal.toDouble();
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
                            elapsedTimeMinutes = totalTimeMinutes -
                                (timer1EndTotal - rtcTotalMinutes);
                          } else {
                            elapsedTimeMinutes = 0;
                          }
                        }
                        timer1Progress = elapsedTimeMinutes / totalTimeMinutes;

                        ///
                        timer2Start24Hour = timersData[6];
                        if (timer2Start24Hour == 0) {
                          timer2Start12Hour = 12;
                          timer2StartAmPm = 'am';
                        } else if (timer2Start24Hour < 13) {
                          timer2Start12Hour = timer2Start24Hour;
                          timer2StartAmPm = 'am';
                          if (timer2Start12Hour == 12) {
                            timer2StartAmPm = 'pm';
                          }
                        } else {
                          timer2Start12Hour = timer2Start24Hour - 12;
                          timer2StartAmPm = 'pm';
                        }
                        timer2StartMinutes = timersData[7];
                        timer2DurationTotal =
                            (timersData[8] << 8) | (timersData[9]);
                        timer2DurationHour = (timer2DurationTotal / 60).floor();
                        timer2DurationMinutes = timer2DurationTotal % 60;
                        timer2RunTime = timer2DurationTotal.toDouble();
                        timer2EndTotal = timer2Start24Hour * 60 +
                            timer2StartMinutes +
                            timer2DurationTotal;
                        if (timer2EndTotal > 1440) {
                          timer2EndTotal -= 1440;
                        }
                        timer2End24Hour = (timer2EndTotal / 60).floor();
                        if (timer2End24Hour == 0) {
                          timer2End12Hour = 12;
                          timer2EndAmPm = 'am';
                        } else if (timer2End24Hour < 13) {
                          timer2End12Hour = timer2End24Hour;
                          timer2EndAmPm = 'am';
                          if (timer2End12Hour == 12) {
                            timer2EndAmPm = 'pm';
                          }
                        } else {
                          timer2End12Hour = timer2End24Hour - 12;
                          timer2EndAmPm = 'pm';
                        }
                        timer2EndMinutes = timer2EndTotal % 60;
                        rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
                        timer2StartTotalMinutes =
                            timer2Start24Hour * 60 + timer2StartMinutes;
                        if (timer2EndTotal > timer2StartTotalMinutes) {
                          totalTimeMinutes =
                              timer2EndTotal - timer2StartTotalMinutes;
                          if (rtcTotalMinutes < timer2StartTotalMinutes) {
                            elapsedTimeMinutes = 0;
                          } else if (rtcTotalMinutes < timer2EndTotal) {
                            elapsedTimeMinutes =
                                rtcTotalMinutes - timer2StartTotalMinutes;
                          } else {
                            elapsedTimeMinutes = totalTimeMinutes;
                          }
                        } else {
                          totalTimeMinutes =
                              1440 - (timer2StartTotalMinutes - timer2EndTotal);
                          if (rtcTotalMinutes > timer2StartTotalMinutes) {
                            elapsedTimeMinutes =
                                rtcTotalMinutes - timer2StartTotalMinutes;
                          } else if (rtcTotalMinutes < timer2EndTotal) {
                            elapsedTimeMinutes = totalTimeMinutes -
                                (timer2EndTotal - rtcTotalMinutes);
                          } else {
                            elapsedTimeMinutes = 0;
                          }
                        }
                        timer2Progress = elapsedTimeMinutes / totalTimeMinutes;

                        ///
                        timer3Start24Hour = timersData[12];
                        if (timer3Start24Hour == 0) {
                          timer3Start12Hour = 12;
                          timer3StartAmPm = 'am';
                        } else if (timer3Start24Hour < 13) {
                          timer3Start12Hour = timer3Start24Hour;
                          timer3StartAmPm = 'am';
                          if (timer3Start12Hour == 12) {
                            timer3StartAmPm = 'pm';
                          }
                        } else {
                          timer3Start12Hour = timer3Start24Hour - 12;
                          timer3StartAmPm = 'pm';
                        }
                        timer3StartMinutes = timersData[13];
                        timer2DurationTotal =
                            (timersData[14] << 8) | (timersData[15]);
                        timer3DurationHour = (timer3DurationTotal / 60).floor();
                        timer3DurationMinutes = timer3DurationTotal % 60;
                        timer3RunTime = timer3DurationTotal.toDouble();
                        timer3EndTotal = timer3Start24Hour * 60 +
                            timer3StartMinutes +
                            timer3DurationTotal;
                        if (timer3EndTotal > 1440) {
                          timer3EndTotal -= 1440;
                        }
                        timer3End24Hour = (timer3EndTotal / 60).floor();
                        if (timer3End24Hour == 0) {
                          timer3End12Hour = 12;
                          timer3EndAmPm = 'am';
                        } else if (timer3End24Hour < 13) {
                          timer3End12Hour = timer3End24Hour;
                          timer3EndAmPm = 'am';
                          if (timer3End12Hour == 12) {
                            timer3EndAmPm = 'pm';
                          }
                        } else {
                          timer3End12Hour = timer3End24Hour - 12;
                          timer3EndAmPm = 'pm';
                        }
                        timer3EndMinutes = timer3EndTotal % 60;
                        rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
                        timer3StartTotalMinutes =
                            timer3Start24Hour * 60 + timer3StartMinutes;
                        if (timer3EndTotal > timer3StartTotalMinutes) {
                          totalTimeMinutes =
                              timer3EndTotal - timer3StartTotalMinutes;
                          if (rtcTotalMinutes < timer3StartTotalMinutes) {
                            elapsedTimeMinutes = 0;
                          } else if (rtcTotalMinutes < timer3EndTotal) {
                            elapsedTimeMinutes =
                                rtcTotalMinutes - timer3StartTotalMinutes;
                          } else {
                            elapsedTimeMinutes = totalTimeMinutes;
                          }
                        } else {
                          totalTimeMinutes =
                              1440 - (timer3StartTotalMinutes - timer3EndTotal);
                          if (rtcTotalMinutes > timer3StartTotalMinutes) {
                            elapsedTimeMinutes =
                                rtcTotalMinutes - timer3StartTotalMinutes;
                          } else if (rtcTotalMinutes < timer3EndTotal) {
                            elapsedTimeMinutes = totalTimeMinutes -
                                (timer3EndTotal - rtcTotalMinutes);
                          } else {
                            elapsedTimeMinutes = 0;
                          }
                        }
                        timer3Progress = elapsedTimeMinutes / totalTimeMinutes;

                        ///
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
                          timer2End12Hour: timer2End12Hour,
                          timer2EndAmPm: timer2EndAmPm,
                          timer2EndMinutes: timer2EndMinutes,
                          timer2Progress: timer2Progress,
                          timer2Start12Hour: timer2Start12Hour,
                          timer2StartAmPm: timer2StartAmPm,
                          timer2StartMinutes: timer2StartMinutes,
                          timer3End12Hour: timer3End12Hour,
                          timer3EndAmPm: timer3EndAmPm,
                          timer3EndMinutes: timer3EndMinutes,
                          timer3Progress: timer3Progress,
                          timer3Start12Hour: timer3Start12Hour,
                          timer3StartAmPm: timer3StartAmPm,
                          timer3StartMinutes: timer3StartMinutes,
                        );
                      },
                    );
                  },
                );
              },
            ),
            StreamBuilder(
                stream: runModeController.stream,
                builder: (context, runModeSnapshot) {
                  if (runModeSnapshot.hasData) {
                    runModeData = runModeSnapshot.data;
                  }
                  chRunMode = (runModeData[0] >> 4) & 0xF;
                  ozRunMode = runModeData[1] & 0xF;
                  prRunMode = (runModeData[1] >> 4) & 0xF;
                  return Chlorinator(
                    device: widget.device,
                    flutterReactiveBle: widget.flutterReactiveBle,
                    connection: widget.connection,
                    chAverageCurrent: chAverageCurrent,
                    chMaxCurrent: chMaxCurrent,
                    chSetPoint: chSetPoint,
                    chPeriod: chPeriod,
                    chTemperature: chTemperature,
                    chStatusData: chStatusData,
                    chRunMode: chRunMode,
                    cpuStatusData: cpuStatusData,
                  );
                }),
            Ozone(
              connection: widget.connection,
              device: widget.device,
              flutterReactiveBle: widget.flutterReactiveBle,
              ozAverageCurrent: ozAverageCurrent,
              ozRunMode: ozRunMode,
              ozSetPoint: ozSetPoint,
              ozStatusData: ozStatusData,
              ozTemperature: ozTemperature,
              cpuStatusData: cpuStatusData,
            ),
            Probes(
              device: widget.device,
              flutterReactiveBle: widget.flutterReactiveBle,
              prOrp: prOrp,
              prPH: prPH,
              prRunMode: prRunMode,
              prStatusData: prStatusData,
              prTemperature: prTemperature,
              prWaterFlow: prWaterFlow,
              cpuStatusData: cpuStatusData,
            ),
          ],
        ),
      ),
    );
  }
}
