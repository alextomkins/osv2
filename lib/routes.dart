import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/main.dart';

class TurnOn extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? initRunMode;
  final List<int>? initRtc;
  final List<int>? initCpuStatus;

  const TurnOn({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    this.initRunMode,
    this.initRtc,
    this.initCpuStatus,
  }) : super(key: key);

  @override
  State<TurnOn> createState() => _TurnOnState();
}

List<bool> isSelected = [false, false, false];
List<String> monthString = [
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
const int CPU_STATUS_CH_DETECT_BIT = 2;
const int CPU_STATUS_OZ_DETECT_BIT = 3;
const int CPU_STATUS_PR_DETECT_BIT = 1;

class _TurnOnState extends State<TurnOn> {
  final Uuid cpuModuleserviceUuid =
      Uuid.parse('388a4ae7-f276-4321-b227-6cd344f0bb7d');

  final Uuid cpuStatusCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a00');
  final Uuid rtcCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a02');
  final Uuid runModeCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a03');
  final Uuid writeCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a06');

  Stream<List<int>>? cpuStatusSubscriptionStream;
  Stream<List<int>>? rtcSubscriptionStream;
  Stream<List<int>>? runModeSubscriptionStream;
  List<int>? runModeData = [0, 0];
  List<int>? rtcData = [0, 0, 0, 0, 0, 1, 0];
  List<int>? cpuStatusData = [0, 0];
  // List<int>? initRunMode = [0, 0];
  // List<int>? initRtc = [0, 0, 0, 0, 0, 1, 0];
  // List<int>? initCpuStatus = [0, 0];
  int runMode = 0;

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

  void _initVariables() async {
    initCpuStatus = await widget.flutterReactiveBle.readCharacteristic(
        QualifiedCharacteristic(
            characteristicId: cpuStatusCharacteristicUuid,
            serviceId: cpuModuleserviceUuid,
            deviceId: widget.device.id));
    initRtc = await widget.flutterReactiveBle.readCharacteristic(
        QualifiedCharacteristic(
            characteristicId: rtcCharacteristicUuid,
            serviceId: cpuModuleserviceUuid,
            deviceId: widget.device.id));
    initRunMode = await widget.flutterReactiveBle.readCharacteristic(
        QualifiedCharacteristic(
            characteristicId: runModeCharacteristicUuid,
            serviceId: cpuModuleserviceUuid,
            deviceId: widget.device.id));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    //_initVariables();
    setState(() {});
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
            icon: const Icon(Icons.remove_circle),
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
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: StreamBuilder<List<int>>(
          stream: runModeSubscriptionStream,
          builder: (runModecontext, runModesnapshot) {
            if (runModesnapshot.hasData) {
              runModeData = runModesnapshot.data;
            } else {
              runModeData = initRunMode;
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
                      } else {
                        cpuStatusData = initCpuStatus;
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
                                onPressed: () {},
                                icon: Image.asset(
                                  'lib/assets/icon_ozone_2_20px.png',
                                  color: ozoneColor,
                                )),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: IconButton(
                                    onPressed: () {},
                                    icon: Image.asset(
                                      'lib/assets/icon_chlorine_1_20px.png',
                                      color: chlorineColor,
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: IconButton(
                                    onPressed: () {},
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
                Stack(children: [
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
                      child: Column(
                        children: [
                          StreamBuilder<List<int>>(
                            stream: rtcSubscriptionStream,
                            builder: (rtcContext, rtcSnapshot) {
                              if (rtcSnapshot.hasData) {
                                rtcData = rtcSnapshot.data;
                              } else {
                                rtcData = initRtc;
                              }
                              int rtcHours;
                              String rtcAmpm;
                              if (rtcData![2] == 0) {
                                rtcHours = 12;
                                rtcAmpm = 'am';
                              } else if (rtcData![2] < 13) {
                                rtcHours = rtcData![2];
                                rtcAmpm = 'am';
                                if (rtcHours == 12) {
                                  rtcAmpm = 'pm';
                                }
                              } else {
                                rtcHours = rtcData![2] - 12;
                                rtcAmpm = 'pm';
                              }
                              int rtcMinutes = rtcData![1];
                              int rtcDayOfWeek = rtcData![3];
                              int rtcDay = rtcData![4];
                              int rtcMonth = rtcData![5];

                              return Column(
                                children: [
                                  Text(
                                    dayString[rtcDayOfWeek],
                                    style: const TextStyle(
                                        fontSize: 30.0,
                                        color: Color.fromRGBO(53, 62, 71, 1)),
                                  ),
                                  Text(
                                    '$rtcHours:${rtcMinutes.toString().padLeft(2, '0')}$rtcAmpm',
                                    style: const TextStyle(
                                        fontSize: 60.0,
                                        fontWeight: FontWeight.bold,
                                        color: Color.fromRGBO(53, 62, 71, 1)),
                                  ),
                                  Text(
                                    '$rtcDay ${monthString[rtcMonth - 1]}',
                                    style: const TextStyle(
                                        fontSize: 30.0,
                                        color: Color.fromRGBO(53, 62, 71, 1)),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
                Padding(
                  padding: const EdgeInsets.only(top: 15.0),
                  child: Visibility(
                    visible: (runMode == 1),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(left: 40.0),
                              child: Column(
                                children: const [
                                  Text('Start Time',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color:
                                              Color.fromRGBO(53, 62, 71, 1))),
                                  Text('10:00am',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          color:
                                              Color.fromRGBO(88, 201, 223, 1))),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 40.0),
                              child: Column(
                                children: const [
                                  Text('Stop Time',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color:
                                              Color.fromRGBO(53, 62, 71, 1))),
                                  Text('06:00pm',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20.0,
                                          color:
                                              Color.fromRGBO(88, 201, 223, 1))),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.only(top: 20.0),
                          child: SizedBox(
                              width: 250.0,
                              height: 35.0,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(20.0)),
                                child: LinearProgressIndicator(
                                  value: 0.2,
                                  backgroundColor:
                                      Color.fromRGBO(53, 62, 71, 200),
                                  color: Color.fromRGBO(88, 201, 223, 1),
                                ),
                              )),
                        ),
                      ],
                    ),
                  ),
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
                          final writeCharacteristic = QualifiedCharacteristic(
                              serviceId: cpuModuleserviceUuid,
                              characteristicId: writeCharacteristicUuid,
                              deviceId: widget.device.id);
                          await widget.flutterReactiveBle
                              .writeCharacteristicWithResponse(
                                  writeCharacteristic,
                                  value: [(buttonSelected + 100)]);
                          await Future.delayed(const Duration(seconds: 1));
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
