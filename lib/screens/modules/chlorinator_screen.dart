import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/util/uuid_constants.dart';

import '../../util/custom_dialogs.dart';

TextStyle mainTitle = const TextStyle(
    color: Color.fromRGBO(53, 62, 71, 1),
    fontSize: 36.0,
    fontWeight: FontWeight.bold);
TextStyle subTitles =
    const TextStyle(color: Color.fromRGBO(53, 62, 71, 1), fontSize: 20.0);
TextStyle values =
    const TextStyle(color: Color.fromRGBO(88, 201, 223, 1), fontSize: 20.0);
TextStyle valuesGreen = const TextStyle(color: Colors.green, fontSize: 20.0);
TextStyle valuesRed = const TextStyle(color: Colors.red, fontSize: 20.0);

class Chlorinator extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int> cpuStatusData;
  final int chAverageCurrent;
  final int chMaxCurrent;
  final int chSetPoint;
  final int chPeriod;
  final double chTemperature;
  final List<int> chStatusData;
  final int chRunMode;

  const Chlorinator({
    super.key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.chAverageCurrent,
    required this.chMaxCurrent,
    required this.chSetPoint,
    required this.chPeriod,
    required this.chTemperature,
    required this.chStatusData,
    required this.chRunMode,
    required this.cpuStatusData,
  });

  @override
  State<Chlorinator> createState() => _ChlorinatorState();
}

List<bool> isSelected = [false, false, false];

class _ChlorinatorState extends State<Chlorinator> {
  int chSetPoint = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Padding(
      padding: const EdgeInsets.all(10.0),
      child: !checkBit(widget.cpuStatusData[0], 2)
          ? const Center(
              child: Text(
              'No Chlorinator Module Detected',
              style: TextStyle(
                  color: Color.fromRGBO(53, 62, 71, 1),
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold),
            ))
          : Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Chlorine Module',
                    style: mainTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Average Current:',
                      style: subTitles,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20.0),
                      child: Text(
                        '${widget.chAverageCurrent} mA',
                        style: values,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Maximum Current:',
                        style: subTitles,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Text(
                          '${widget.chMaxCurrent} mA',
                          style: values,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 5.0),
                      child: Text(
                        'Setpoint',
                        style: subTitles,
                      ),
                    ),
                    Visibility(
                      visible: widget.chRunMode == 1,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(left: 110.0, bottom: 5.0),
                        child: SizedBox(
                          height: 20.0,
                          child: IconButton(
                              padding: EdgeInsets.zero,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return ChlorineChangeSetpoint(
                                      device: widget.device,
                                      flutterReactiveBle:
                                          widget.flutterReactiveBle,
                                      setpoint: widget.chSetPoint,
                                    );
                                  },
                                );
                              },
                              icon: const Icon(
                                Icons.edit,
                                color: Color.fromRGBO(53, 62, 71, 1),
                                size: 20.0,
                              )),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 250.0,
                  height: 35.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: LinearProgressIndicator(
                      value: widget.chSetPoint / 100,
                      backgroundColor: const Color.fromRGBO(53, 62, 71, 200),
                      color: const Color.fromRGBO(88, 201, 223, 1),
                    ),
                  ),
                ),
                Text(
                  '${widget.chSetPoint}%',
                  style: values,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 5.0,
                  ),
                  child: Text(
                    'Period',
                    style: subTitles,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 250.0,
                  height: 35.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: LinearProgressIndicator(
                      value: widget.chPeriod / 1000,
                      backgroundColor: const Color.fromRGBO(53, 62, 71, 200),
                      color: const Color.fromRGBO(88, 201, 223, 1),
                    ),
                  ),
                ),
                Text(
                  '${widget.chPeriod}',
                  style: values,
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10.0,
                    bottom: 5.0,
                  ),
                  child: Text(
                    'Temperature',
                    style: subTitles,
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 250.0,
                  height: 35.0,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(20.0)),
                    child: LinearProgressIndicator(
                      value: widget.chTemperature / 100,
                      backgroundColor: const Color.fromRGBO(53, 62, 71, 200),
                      color: const Color.fromRGBO(88, 201, 223, 1),
                    ),
                  ),
                ),
                Text(
                  '${widget.chTemperature} \u2103',
                  style: checkBit(widget.chStatusData[0], 2)
                      ? const TextStyle(color: Colors.red, fontSize: 20.0)
                      : const TextStyle(
                          color: Color.fromRGBO(88, 201, 223, 1),
                          fontSize: 20.0),
                  textAlign: TextAlign.center,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      checkBit(widget.chStatusData[0], 0)
                          ? Text(
                              'Running',
                              style: valuesGreen,
                            )
                          : Text(
                              'Not Running',
                              style: valuesRed,
                            ),
                      Padding(
                        padding: const EdgeInsets.only(left: 15.0),
                        child: !checkBit(widget.chStatusData[0], 1)
                            ? Text(
                                'Water Detected',
                                style: valuesGreen,
                              )
                            : Text(
                                'No Water',
                                style: valuesRed,
                              ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    !checkBit(widget.chStatusData[0], 2)
                        ? Text(
                            'Temperature Good',
                            style: valuesGreen,
                          )
                        : Text(
                            'Overheated',
                            style: valuesRed,
                          ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: checkBit(widget.chStatusData[0], 3)
                          ? Text(
                              'Low Salt',
                              style: valuesRed,
                            )
                          : checkBit(widget.chStatusData[0], 4)
                              ? Text(
                                  'High Salt',
                                  style: valuesRed,
                                )
                              : Text(
                                  'Salt Level Good',
                                  style: valuesGreen,
                                ),
                    ),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: ToggleButtons(
                        constraints: const BoxConstraints.expand(width: 100),
                        borderRadius: BorderRadius.circular(10.0),
                        borderColor: const Color.fromRGBO(53, 62, 71, 1),
                        isSelected: widget.chRunMode == 0
                            ? [true, false, false]
                            : widget.chRunMode == 1
                                ? [false, true, false]
                                : [false, false, true],
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
                                    value: [(buttonSelected + 110)]);
                          }
                        },
                        fillColor: const Color.fromRGBO(53, 62, 71, 1),
                        selectedBorderColor:
                            const Color.fromRGBO(53, 62, 71, 1),
                        color: const Color.fromRGBO(53, 62, 71, 1),
                        selectedColor: Colors.white,
                        children: const <Widget>[
                          Text(
                            "Disable",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "Setpoint",
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Text(
                            "Max",
                            style: TextStyle(fontSize: 20.0),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    ));
  }
}
