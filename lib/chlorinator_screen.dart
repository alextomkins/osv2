import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/uuid_constants.dart';

TextStyle mainTitle =
    TextStyle(color: Color.fromRGBO(53, 62, 71, 1), fontSize: 24.0);
TextStyle subTitles =
    TextStyle(color: Color.fromRGBO(53, 62, 71, 1), fontSize: 18.0);
TextStyle values =
    TextStyle(color: Color.fromRGBO(88, 201, 223, 1), fontSize: 12.0);
TextStyle valuesGreen = TextStyle(color: Colors.green, fontSize: 12.0);
TextStyle valuesRed = TextStyle(color: Colors.red, fontSize: 12.0);

class Chlorinator extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  const Chlorinator(
      {super.key,
      required this.device,
      required this.flutterReactiveBle,
      required this.connection});

  @override
  State<Chlorinator> createState() => _ChlorinatorState();
}

class _ChlorinatorState extends State<Chlorinator> {
  int averageCurrent = 0;
  int maxCurrent = 0;
  int setpoint = 0;
  int period = 0;
  double temperature = 0.0;
  List<int> chStatusData = [0, 0];
  bool cancelTimer = false;

  @override
  void dispose() {
    super.dispose();
    cancelTimer = true;
  }

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (cancelTimer == true) {
        timer.cancel();
      } else {
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
        setpoint = chValuesData[4];
        period = (chValuesData[5] << 8) | (chValuesData[6]);
        temperature =
            ((chValuesData[7] << 8) | (chValuesData[8])).toDouble() / 10;
        setState(() {});
      }
    });
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      children: [
        Text(
          'Chlorine Module',
          style: mainTitle,
        ),
        Text(
          'Average Current',
          style: subTitles,
        ),
        Text(
          '$averageCurrent mA',
          style: values,
        ),
        Text(
          'Maximum Current',
          style: subTitles,
        ),
        Text(
          '$maxCurrent mA',
          style: values,
        ),
        Text(
          'Setpoint',
          style: subTitles,
        ),
        Text(
          '$setpoint',
          style: values,
        ),
        Text(
          'Period',
          style: subTitles,
        ),
        Text(
          '$period',
          style: values,
        ),
        Text(
          'Temperature',
          style: subTitles,
        ),
        Text(
          '$temperature \u2103',
          style: values,
        ),
        checkBit(chStatusData[0], 0)
            ? Text(
                'Running',
                style: valuesGreen,
              )
            : Text(
                'Not Running',
                style: valuesRed,
              ),
        !checkBit(chStatusData[0], 1)
            ? Text(
                'Water Detected',
                style: valuesGreen,
              )
            : Text(
                'No Water',
                style: valuesRed,
              ),
        !checkBit(chStatusData[0], 2)
            ? Text(
                'Fine Heat',
                style: valuesGreen,
              )
            : Text(
                'Overheated',
                style: valuesRed,
              ),
        checkBit(chStatusData[0], 3)
            ? Text(
                'Low Salt',
                style: valuesRed,
              )
            : checkBit(chStatusData[0], 4)
                ? Text(
                    'High Salt',
                    style: valuesRed,
                  )
                : Text(
                    'Salt Level Good',
                    style: valuesGreen,
                  ),
        !checkBit(chStatusData[0], 0)
            ? Text(
                'Current Detected',
                style: valuesGreen,
              )
            : Text(
                'No Current',
                style: valuesRed,
              ),
      ],
    ));
  }
}
