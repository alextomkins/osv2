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

class _MainScreenState extends State<MainScreen> {
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
                      timer1Progress =
                          timer1ElapsedMinutes / timer1DurationTotal;
                    } else {
                      timer1Progress = 1.0;
                    }
                    setState(() {});
                  });
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
            HomeScreen(
              device: widget.device,
              flutterReactiveBle: widget.flutterReactiveBle,
              connection: widget.connection,
              cpuStatusData: cpuStatusData,
              rtcData: rtcData,
              runModeData: runModeData,
              timersData: timersData,
            ),
            Chlorinator(
              device: widget.device,
              flutterReactiveBle: widget.flutterReactiveBle,
              connection: widget.connection,
            ),
            const Ozone(),
            const Probes(),
          ],
        ),
      ),
    );
  }
}
