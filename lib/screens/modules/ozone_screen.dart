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

class Ozone extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int> cpuStatusData;
  final int ozAverageCurrent;
  final int ozSetPoint;
  final double ozTemperature;
  final List<int> ozStatusData;
  final int ozRunMode;

  const Ozone({
    super.key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.ozAverageCurrent,
    required this.ozSetPoint,
    required this.ozTemperature,
    required this.ozStatusData,
    required this.ozRunMode,
    required this.cpuStatusData,
  });

  @override
  State<Ozone> createState() => _OzoneState();
}

List<bool> isSelected = [false, false, false];

class _OzoneState extends State<Ozone> {
  int chSetPoint = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !checkBit(widget.cpuStatusData[0], 3)
            ? const Center(
                child: Text(
                'No Ozone Module Detected',
                style: TextStyle(
                    color: Color.fromRGBO(53, 62, 71, 1),
                    fontSize: 25.0,
                    fontWeight: FontWeight.bold),
              ))
            : Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Text(
                        'Ozone Module',
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
                            '${widget.ozAverageCurrent} mA',
                            style: values,
                          ),
                        ),
                      ],
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
                          visible: widget.ozRunMode == 1,
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
                                        return OzoneChangeSetpoint(
                                          device: widget.device,
                                          flutterReactiveBle:
                                              widget.flutterReactiveBle,
                                          setpoint: widget.ozSetPoint,
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        child: LinearProgressIndicator(
                          value: widget.ozSetPoint / 100,
                          backgroundColor:
                              const Color.fromRGBO(53, 62, 71, 200),
                          color: const Color.fromRGBO(88, 201, 223, 1),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.ozSetPoint}%',
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
                        borderRadius:
                            const BorderRadius.all(Radius.circular(20.0)),
                        child: LinearProgressIndicator(
                          value: widget.ozTemperature / 100,
                          backgroundColor:
                              const Color.fromRGBO(53, 62, 71, 200),
                          color: const Color.fromRGBO(88, 201, 223, 1),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.ozTemperature} \u2103',
                      style: checkBit(widget.ozStatusData[0], 1)
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
                          checkBit(widget.ozStatusData[0], 0)
                              ? Text(
                                  'Running',
                                  style: valuesGreen,
                                )
                              : Text(
                                  'Not Running',
                                  style: valuesRed,
                                ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ToggleButtons(
                            constraints:
                                const BoxConstraints.expand(width: 100),
                            borderRadius: BorderRadius.circular(10.0),
                            borderColor: const Color.fromRGBO(53, 62, 71, 1),
                            isSelected: widget.ozRunMode == 0
                                ? [true, false, false]
                                : widget.ozRunMode == 1
                                    ? [false, true, false]
                                    : [false, false, true],
                            onPressed: (int buttonSelected) async {
                              final commandCharacteristic =
                                  QualifiedCharacteristic(
                                      serviceId: cpuModuleServiceUuid,
                                      characteristicId:
                                          commandCharacteristicUuid,
                                      deviceId: widget.device.id);
                              final commandResponse = await widget
                                  .flutterReactiveBle
                                  .readCharacteristic(commandCharacteristic);
                              if (commandResponse[0] == 0) {
                                await widget.flutterReactiveBle
                                    .writeCharacteristicWithResponse(
                                        commandCharacteristic,
                                        value: [(buttonSelected + 120)]);
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
