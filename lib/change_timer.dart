import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:intl/intl.dart';
import 'package:osv2/main.dart';

class ChangeTimer extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? timersData;

  const ChangeTimer({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.timersData,
  }) : super(key: key);

  @override
  State<ChangeTimer> createState() => _ChangeTimerState();
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

class _ChangeTimerState extends State<ChangeTimer> {
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
  double runTime = 0;
  TimeOfDay? selectedTime;

  void _initTimers() {
    timer1Start = DateTime(today.year, today.month, today.day,
        widget.timersData![0], widget.timersData![1]);
    timer1Duration = Duration(
        minutes: (widget.timersData![2] << 8) | (widget.timersData![3]));
    timer1End = timer1Start.add(timer1Duration);
    runTime = double.parse(
        '${timer1Duration.toString().split(":")[0]}.${(int.parse(timer1Duration.toString().split(":")[1]) / 60).floor()}');
    selectedTime = TimeOfDay.fromDateTime(timer1Start);
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
    _initTimers();
    _initStream();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Set Duration and Days",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                  left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
              child: Column(
                children: [
                  const Text(
                    'Start Time',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(88, 200, 223, 1),
                    ),
                  ),
                  Text(
                    '${DateFormat('hh:mm').format(timer1Start)}${DateFormat('a').format(timer1Start).toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 27,
                      color: Color.fromRGBO(53, 62, 71, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                    child: SizedBox(
                      width: 130,
                      height: 55,
                      child: ElevatedButton(
                          onPressed: () async {
                            selectedTime = await showTimePicker(
                              initialTime: TimeOfDay(
                                  hour: timer1Start.hour,
                                  minute: timer1Start.minute),
                              context: context,
                            );
                            if (selectedTime != null) {
                              timer1Start = DateTime(
                                  timer1Start.year,
                                  timer1Start.month,
                                  timer1Start.day,
                                  selectedTime!.hour,
                                  selectedTime!.minute,
                                  timer1Start.second);
                            }
                            timer1Duration = Duration(
                                hours: runTime.floor(),
                                minutes:
                                    ((runTime - runTime.floor()) * 60).floor());
                            timer1End = timer1Start.add(timer1Duration);
                            setState(() {});
                          },
                          child: const Text('Set Time',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0))),
                    ),
                  ),
                  const Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(88, 200, 223, 1),
                    ),
                  ),
                  Text(
                      '${runTime.floor()} hours ${((runTime - runTime.floor()) * 60).floor()} minutes',
                      style: const TextStyle(fontSize: 18.0)),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(trackHeight: 16.0),
                    child: Slider(
                      value: runTime,
                      onChanged: (newRunTime) {
                        runTime = newRunTime;
                        timer1Duration = Duration(
                            hours: runTime.floor(),
                            minutes:
                                ((runTime - runTime.floor()) * 60).floor());
                        timer1End = timer1Start.add(timer1Duration);
                        setState(() {});
                      },
                      min: 0,
                      max: 10,
                      divisions: 40,
                    ),
                  ),
                  const Text(
                    'Stop Time',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(88, 200, 223, 1),
                    ),
                  ),
                  Text(
                    '${DateFormat('hh:mm').format(timer1End)}${DateFormat('a').format(timer1End).toLowerCase()}',
                    style: const TextStyle(
                      fontSize: 27,
                      color: Color.fromRGBO(53, 62, 71, 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(53, 62, 71, 1)),
                          ),
                          child: const Text('Mon'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(53, 62, 71, 1)),
                          ),
                          child: const Text('Tues'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(53, 62, 71, 1)),
                          ),
                          child: const Text('Wed'),
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all(const CircleBorder()),
                            padding: MaterialStateProperty.all(
                                const EdgeInsets.all(20)),
                            backgroundColor: MaterialStateProperty.all(
                                Color.fromRGBO(53, 62, 71, 1)),
                          ),
                          child: const Text('Thurs'),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20)),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(53, 62, 71, 1)),
                        ),
                        child: const Text('Fri'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20)),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(53, 62, 71, 1)),
                        ),
                        child: const Text('Sat'),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(const CircleBorder()),
                          padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20)),
                          backgroundColor: MaterialStateProperty.all(
                              Color.fromRGBO(53, 62, 71, 1)),
                        ),
                        child: const Text('Sun'),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: ElevatedButton(
                      onPressed: () async {
                        if (selectedTime != null) {
                          final commandCharacteristic = QualifiedCharacteristic(
                              serviceId: cpuModuleserviceUuid,
                              characteristicId: commandCharacteristicUuid,
                              deviceId: widget.device.id);
                          final commandResponse = await widget
                              .flutterReactiveBle
                              .readCharacteristic(commandCharacteristic);
                          if (commandResponse[0] == 0) {
                            await widget.flutterReactiveBle
                                .writeCharacteristicWithResponse(
                                    commandCharacteristic,
                                    value: [
                                  3,
                                  selectedTime!.hour,
                                  selectedTime!.minute,
                                  timer1Duration.inMinutes >> 8,
                                  timer1Duration.inMinutes & 0xFF,
                                  0x7F,
                                ]);
                          }
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}