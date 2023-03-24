import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/util/uuid_constants.dart';

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

class Probes extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final List<int> cpuStatusData;
  final int prWaterFlow;
  final int prPH;
  final int prOrp;
  final double prTemperature;
  final List<int> prStatusData;
  final int prRunMode;

  const Probes({
    super.key,
    required this.device,
    required this.flutterReactiveBle,
    required this.prWaterFlow,
    required this.prPH,
    required this.prOrp,
    required this.prTemperature,
    required this.prStatusData,
    required this.prRunMode,
    required this.cpuStatusData,
  });

  @override
  State<Probes> createState() => _ProbesState();
}

List<bool> isSelected = [false, false, false];

class _ProbesState extends State<Probes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: !checkBit(widget.cpuStatusData[1], 1)
            ? const Center(
                child: Text(
                'No Probes Module Detected',
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
                        'Probes Module',
                        style: mainTitle,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        'Water Flow Rate',
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
                          value: widget.prWaterFlow / 100,
                          backgroundColor:
                              const Color.fromRGBO(53, 62, 71, 200),
                          color: const Color.fromRGBO(88, 201, 223, 1),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.prWaterFlow}',
                      style: const TextStyle(
                          color: Color.fromRGBO(88, 201, 223, 1),
                          fontSize: 20.0),
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
                          value: widget.prTemperature / 100,
                          backgroundColor:
                              const Color.fromRGBO(53, 62, 71, 200),
                          color: const Color.fromRGBO(88, 201, 223, 1),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.prTemperature} \u2103',
                      style: const TextStyle(
                          color: Color.fromRGBO(88, 201, 223, 1),
                          fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        'Ph Value',
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
                          value: widget.prPH / 100,
                          backgroundColor:
                              const Color.fromRGBO(53, 62, 71, 200),
                          color: const Color.fromRGBO(88, 201, 223, 1),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.prPH}',
                      style: const TextStyle(
                          color: Color.fromRGBO(88, 201, 223, 1),
                          fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 10.0,
                        bottom: 5.0,
                      ),
                      child: Text(
                        'Orp Value',
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
                          value: widget.prOrp / 100,
                          backgroundColor:
                              const Color.fromRGBO(53, 62, 71, 200),
                          color: const Color.fromRGBO(88, 201, 223, 1),
                        ),
                      ),
                    ),
                    Text(
                      '${widget.prOrp}',
                      style: const TextStyle(
                          color: Color.fromRGBO(88, 201, 223, 1),
                          fontSize: 20.0),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0),
                      child: Column(
                        children: [
                          checkBit(widget.prStatusData[0], 0)
                              ? Text(
                                  'Pump 1 Running',
                                  style: valuesGreen,
                                )
                              : Text(
                                  'Pump 1 Not Running',
                                  style: valuesRed,
                                ),
                          checkBit(widget.prStatusData[0], 1)
                              ? Text(
                                  'Pump 2 Running',
                                  style: valuesGreen,
                                )
                              : Text(
                                  'Pump 2 Not Running',
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
                            isSelected: widget.prRunMode == 0
                                ? [true, false, false]
                                : widget.prRunMode == 1
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
                                        value: [(buttonSelected + 130)]);
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
                                "Auto",
                                style: TextStyle(fontSize: 20.0),
                              ),
                              Text(
                                "Manual",
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
