import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/uuid_constants.dart';

class OzoneInfoDialog extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final int setpoint;
  final int averageCurrent;
  final int temperature;
  const OzoneInfoDialog(
      {super.key,
      required this.setpoint,
      required this.averageCurrent,
      required this.temperature,
      required this.device,
      required this.flutterReactiveBle});

  @override
  State<StatefulWidget> createState() {
    return _OzoneInfoDialogState();
  }
}

class _OzoneInfoDialogState extends State<OzoneInfoDialog> {
  bool cancelTimer = false;
  int setpoint = 0;
  int averageCurrent = 0;
  int temperature = 0;

  @override
  void initState() {
    setpoint = widget.setpoint;
    averageCurrent = widget.averageCurrent;
    temperature = widget.temperature;
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (cancelTimer == true) {
        timer.cancel();
      } else {
        List<int> ozValuesData = await widget.flutterReactiveBle
            .readCharacteristic(QualifiedCharacteristic(
                characteristicId: ozValuesCharacteristicUuid,
                serviceId: modbusDevicesServiceUuid,
                deviceId: widget.device.id));
        setpoint = ozValuesData[0];
        averageCurrent = (ozValuesData[1] << 8) | (ozValuesData[2]);
        temperature = (ozValuesData[3] << 8) | (ozValuesData[4]);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    cancelTimer = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 20),
              const Text('Ozone Module'),
              const SizedBox(height: 20),
              Text('Setpoint: $setpoint'),
              Text('Average Current: $averageCurrent mA'),
              Text('Temperature: $temperature\u2103'),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class ChlorineInfoDialog extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final int setpoint;
  final int averageCurrent;
  final int temperature;
  final int maxCurrent;
  final int period;
  const ChlorineInfoDialog(
      {super.key,
      required this.setpoint,
      required this.averageCurrent,
      required this.temperature,
      required this.device,
      required this.flutterReactiveBle,
      required this.maxCurrent,
      required this.period});

  @override
  State<StatefulWidget> createState() {
    return _ChlorineInfoDialogState();
  }
}

class _ChlorineInfoDialogState extends State<ChlorineInfoDialog> {
  bool cancelTimer = false;
  int setpoint = 0;
  int averageCurrent = 0;
  int temperature = 0;
  int maxCurrent = 0;
  int period = 0;

  @override
  void initState() {
    setpoint = widget.setpoint;
    averageCurrent = widget.averageCurrent;
    temperature = widget.temperature;
    maxCurrent = widget.maxCurrent;
    period = widget.period;
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
        averageCurrent = (chValuesData[0] << 8) | (chValuesData[1]);
        maxCurrent = (chValuesData[2] << 8) | (chValuesData[3]);
        setpoint = chValuesData[4];
        period = (chValuesData[5] << 8) | (chValuesData[6]);
        temperature = (chValuesData[7] << 8) | (chValuesData[8]);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    cancelTimer = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 20),
              const Text('Chlorine Module'),
              const SizedBox(height: 20),
              Text('Average Current: $averageCurrent mA'),
              Text('Maximum Current: $maxCurrent mA'),
              Text('Setpoint: $setpoint'),
              Text('Period: $period'),
              Text('Temperature: $temperature\u2103'),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}

class ProbesInfoDialog extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final int flowRate;
  final int waterTemperature;
  final int phValue;
  final int orpValue;

  const ProbesInfoDialog({
    super.key,
    required this.device,
    required this.flutterReactiveBle,
    required this.flowRate,
    required this.waterTemperature,
    required this.phValue,
    required this.orpValue,
  });

  @override
  State<StatefulWidget> createState() {
    return _ProbesInfoDialogState();
  }
}

class _ProbesInfoDialogState extends State<ProbesInfoDialog> {
  bool cancelTimer = false;
  int flowRate = 0;
  int waterTemperature = 0;
  int phValue = 0;
  int orpValue = 0;

  @override
  void initState() {
    super.initState();
    Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (cancelTimer == true) {
        timer.cancel();
      } else {
        List<int> prValuesData = await widget.flutterReactiveBle
            .readCharacteristic(QualifiedCharacteristic(
                characteristicId: prValuesCharacteristicUuid,
                serviceId: modbusDevicesServiceUuid,
                deviceId: widget.device.id));
        flowRate = (prValuesData[0] << 8) | (prValuesData[1]);
        waterTemperature = (prValuesData[2] << 8) | (prValuesData[3]);
        phValue = (prValuesData[4] << 8) | (prValuesData[5]);
        orpValue = (prValuesData[6] << 8) | (prValuesData[7]);
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    cancelTimer = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: ListView(
        shrinkWrap: true,
        children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 20),
              const Text('Chlorine Module'),
              const SizedBox(height: 20),
              Text('Water Flow Rate: $flowRate'),
              Text('Water Temperature: $waterTemperature\u2103'),
              Text('pH Value: $phValue'),
              Text('Orp Value: $orpValue'),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }
}
