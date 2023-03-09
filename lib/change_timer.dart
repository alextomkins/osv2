import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/uuid_constants.dart';

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

List<String> dayString = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"];

Color ozoneColor = const Color.fromRGBO(53, 62, 71, 1);
Color chlorineColor = const Color.fromRGBO(53, 62, 71, 1);
Color probeColor = const Color.fromRGBO(53, 62, 71, 1);

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class _ChangeTimerState extends State<ChangeTimer> {
  double runTime = 0;
  TimeOfDay? selectedTime;
  List<int> dayOfWeekList = [0, 0, 0, 0, 0, 0, 0, 0];
  int timer1Start12Hour = 0;
  int timer1Start24Hour = 0;
  String timer1StartAmPm = '';
  int timer1StartMinutes = 0;
  int timer1DurationTotal = 0;
  int timer1DurationHour = 0;
  int timer1DurationMinutes = 0;
  int timer1EndTotal = 0;
  int timer1End24Hour = 0;
  int timer1End12Hour = 0;
  int timer1EndMinutes = 0;
  String timer1EndAmPm = '';
  bool isOn = false;
  String testingString = 'testing';
  List<int>? timersData;

  void _initTimers() {
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
    String initDayOfWeekListBin =
        timersData![4].toRadixString(2).padLeft(8, '0');
    for (var i = 0; i < initDayOfWeekListBin.length; i++) {
      dayOfWeekList[i] = int.parse(initDayOfWeekListBin[i]);
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
    _initTimers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
                  '$timer1Start12Hour:${timer1StartMinutes.toString().padLeft(2, '0')}$timer1StartAmPm',
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
                              hour: timer1Start24Hour,
                              minute: timer1StartMinutes),
                          context: context,
                        );
                        if (selectedTime != null) {
                          timer1Start24Hour = selectedTime!.hour;
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
                          timer1StartMinutes = selectedTime!.minute;

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
                          setState(() {});
                        }
                      },
                      child: const Text(
                        'Set Time',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 22.0),
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Duration',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(88, 200, 223, 1),
                    ),
                  ),
                ),
                Text('$timer1DurationHour hours $timer1DurationMinutes minutes',
                    style: const TextStyle(fontSize: 18.0)),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 16.0),
                  child: Slider(
                    value: runTime,
                    onChanged: (newRunTime) {
                      runTime = newRunTime;
                      timer1DurationTotal = runTime.floor();
                      timer1DurationHour = (timer1DurationTotal / 60).floor();
                      timer1DurationMinutes = timer1DurationTotal % 60;
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
                      setState(() {});
                    },
                    min: 0,
                    max: 600,
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
                  '$timer1End12Hour:${timer1EndMinutes.toString().padLeft(2, '0')}$timer1EndAmPm',
                  style: const TextStyle(
                    fontSize: 27,
                    color: Color.fromRGBO(53, 62, 71, 1),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Text(
                    'Days to Run',
                    style: TextStyle(
                      fontSize: 32,
                      color: Color.fromRGBO(88, 200, 223, 1),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            dayOfWeekList[1] == 1
                                ? dayOfWeekList[1] = 0
                                : dayOfWeekList[1] = 1;
                            setState(() {});
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              const CircleBorder(),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20),
                            ),
                            backgroundColor: dayOfWeekList[1] == 1
                                ? MaterialStateProperty.all(
                                    const Color.fromRGBO(88, 200, 223, 1))
                                : MaterialStateProperty.all(
                                    const Color.fromRGBO(53, 62, 71, 1),
                                  ),
                          ),
                          child: Text(dayString[1])),
                      ElevatedButton(
                          onPressed: () {
                            dayOfWeekList[2] == 1
                                ? dayOfWeekList[2] = 0
                                : dayOfWeekList[2] = 1;
                            setState(() {});
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              const CircleBorder(),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20),
                            ),
                            backgroundColor: dayOfWeekList[2] == 1
                                ? MaterialStateProperty.all(
                                    const Color.fromRGBO(88, 200, 223, 1))
                                : MaterialStateProperty.all(
                                    const Color.fromRGBO(53, 62, 71, 1),
                                  ),
                          ),
                          child: Text(dayString[2])),
                      ElevatedButton(
                          onPressed: () {
                            dayOfWeekList[3] == 1
                                ? dayOfWeekList[3] = 0
                                : dayOfWeekList[3] = 1;
                            setState(() {});
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              const CircleBorder(),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20),
                            ),
                            backgroundColor: dayOfWeekList[3] == 1
                                ? MaterialStateProperty.all(
                                    const Color.fromRGBO(88, 200, 223, 1))
                                : MaterialStateProperty.all(
                                    const Color.fromRGBO(53, 62, 71, 1),
                                  ),
                          ),
                          child: Text(dayString[3])),
                      ElevatedButton(
                          onPressed: () {
                            dayOfWeekList[4] == 1
                                ? dayOfWeekList[4] = 0
                                : dayOfWeekList[4] = 1;
                            setState(() {});
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              const CircleBorder(),
                            ),
                            padding: MaterialStateProperty.all(
                              const EdgeInsets.all(20),
                            ),
                            backgroundColor: dayOfWeekList[4] == 1
                                ? MaterialStateProperty.all(
                                    const Color.fromRGBO(88, 200, 223, 1))
                                : MaterialStateProperty.all(
                                    const Color.fromRGBO(53, 62, 71, 1),
                                  ),
                          ),
                          child: Text(dayString[4])),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        onPressed: () {
                          dayOfWeekList[5] == 1
                              ? dayOfWeekList[5] = 0
                              : dayOfWeekList[5] = 1;
                          setState(() {});
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            const CircleBorder(),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20),
                          ),
                          backgroundColor: dayOfWeekList[5] == 1
                              ? MaterialStateProperty.all(
                                  const Color.fromRGBO(88, 200, 223, 1))
                              : MaterialStateProperty.all(
                                  const Color.fromRGBO(53, 62, 71, 1),
                                ),
                        ),
                        child: Text(dayString[5])),
                    ElevatedButton(
                        onPressed: () {
                          dayOfWeekList[6] == 1
                              ? dayOfWeekList[6] = 0
                              : dayOfWeekList[6] = 1;
                          setState(() {});
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            const CircleBorder(),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20),
                          ),
                          backgroundColor: dayOfWeekList[6] == 1
                              ? MaterialStateProperty.all(
                                  const Color.fromRGBO(88, 200, 223, 1))
                              : MaterialStateProperty.all(
                                  const Color.fromRGBO(53, 62, 71, 1),
                                ),
                        ),
                        child: Text(dayString[6])),
                    ElevatedButton(
                        onPressed: () {
                          dayOfWeekList[0] == 1
                              ? dayOfWeekList[0] = 0
                              : dayOfWeekList[0] = 1;
                          setState(() {});
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all(
                            const CircleBorder(),
                          ),
                          padding: MaterialStateProperty.all(
                            const EdgeInsets.all(20),
                          ),
                          backgroundColor: dayOfWeekList[0] == 1
                              ? MaterialStateProperty.all(
                                  const Color.fromRGBO(88, 200, 223, 1))
                              : MaterialStateProperty.all(
                                  const Color.fromRGBO(53, 62, 71, 1),
                                ),
                        ),
                        child: Text(dayString[0])),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: SizedBox(
                    width: 120.0,
                    height: 50.0,
                    child: ElevatedButton(
                      onPressed: () async {
                        String dayOfWeekString = dayOfWeekList.join();
                        int dayOfWeekDec = int.parse(dayOfWeekString, radix: 2);
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
                                3,
                                timer1Start24Hour,
                                timer1StartMinutes,
                                timer1DurationTotal >> 8,
                                timer1DurationTotal & 0xFF,
                                dayOfWeekDec,
                              ]);
                        }
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 26.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
