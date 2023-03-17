import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/animations.dart';
import 'package:osv2/uuid_constants.dart';

class HomeScreen extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final String rtcDayOfWeek;
  final int rtc12Hour;
  final int rtcMinutes;
  final String rtcAmPm;
  final int rtcDay;
  final String rtcMonth;
  final List<int> cpuStatusData;
  final int runMode;
  final int timer1Start12Hour;
  final int timer1StartMinutes;
  final String timer1StartAmPm;
  final int timer1End12Hour;
  final int timer1EndMinutes;
  final String timer1EndAmPm;
  final double timer1Progress;

  const HomeScreen({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.rtcDayOfWeek,
    required this.rtc12Hour,
    required this.rtcMinutes,
    required this.rtcAmPm,
    required this.rtcDay,
    required this.rtcMonth,
    required this.cpuStatusData,
    required this.runMode,
    required this.timer1Start12Hour,
    required this.timer1StartMinutes,
    required this.timer1StartAmPm,
    required this.timer1End12Hour,
    required this.timer1EndMinutes,
    required this.timer1EndAmPm,
    required this.timer1Progress,
  }) : super(key: key);

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: Column(
            children: [
              Stack(
                children: [
                  SizedBox(
                      height: 300,
                      width: 300,
                      child: checkBit(widget.cpuStatusData[0], 6)
                          ? const RunningAnimation()
                          : const RunningAnimation()),
                  SizedBox(
                    height: 300,
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          widget.rtcDayOfWeek,
                          style: const TextStyle(
                              fontSize: 30.0,
                              color: Color.fromRGBO(53, 62, 71, 1)),
                        ),
                        Text(
                          '${widget.rtc12Hour}:${widget.rtcMinutes.toString().padLeft(2, '0')}${widget.rtcAmPm}',
                          style: const TextStyle(
                              fontSize: 60.0,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(53, 62, 71, 1)),
                        ),
                        Text(
                          '${widget.rtcDay} ${widget.rtcMonth}',
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
                  opacity: (widget.runMode == 1) ? 1.0 : 0.5,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 40.0),
                            child: Column(
                              children: [
                                const Text('Start Time',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Color.fromRGBO(53, 62, 71, 1))),
                                Text(
                                    '${widget.timer1Start12Hour}:${widget.timer1StartMinutes.toString().padLeft(2, '0')}${widget.timer1StartAmPm}',
                                    style: const TextStyle(
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
                              children: [
                                const Text('Stop Time',
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        color: Color.fromRGBO(53, 62, 71, 1))),
                                Text(
                                    '${widget.timer1End12Hour}:${widget.timer1EndMinutes.toString().padLeft(2, '0')}${widget.timer1EndAmPm}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20.0,
                                        color:
                                            Color.fromRGBO(88, 201, 223, 1))),
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
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(20.0)),
                              child: LinearProgressIndicator(
                                value: widget.timer1Progress,
                                backgroundColor:
                                    const Color.fromRGBO(53, 62, 71, 200),
                                color: const Color.fromRGBO(88, 201, 223, 1),
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
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
                isSelected: widget.runMode == 0
                    ? [true, false, false]
                    : widget.runMode == 1
                        ? [false, true, false]
                        : [false, false, true],
                onPressed: (int buttonSelected) async {
                  final commandCharacteristic = QualifiedCharacteristic(
                      serviceId: cpuModuleServiceUuid,
                      characteristicId: commandCharacteristicUuid,
                      deviceId: widget.device.id);
                  final commandResponse = await widget.flutterReactiveBle
                      .readCharacteristic(commandCharacteristic);
                  if (commandResponse[0] == 0) {
                    await widget.flutterReactiveBle
                        .writeCharacteristicWithResponse(commandCharacteristic,
                            value: [(buttonSelected + 100)]);
                  }
                },
                fillColor: const Color.fromRGBO(53, 62, 71, 1),
                selectedBorderColor: const Color.fromRGBO(53, 62, 71, 1),
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
    ));
  }
}
