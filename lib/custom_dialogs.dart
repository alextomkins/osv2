import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/uuid_constants.dart';

class ChlorineChangeSetpoint extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final int setpoint;
  const ChlorineChangeSetpoint({
    super.key,
    required this.setpoint,
    required this.device,
    required this.flutterReactiveBle,
  });

  @override
  State<StatefulWidget> createState() {
    return _ChlorineChangeSetpointState();
  }
}

class _ChlorineChangeSetpointState extends State<ChlorineChangeSetpoint> {
  int setpoint = 0;

  @override
  void initState() {
    setpoint = widget.setpoint;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Change Setpoint',
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final commandCharacteristic = QualifiedCharacteristic(
                serviceId: cpuModuleServiceUuid,
                characteristicId: commandCharacteristicUuid,
                deviceId: widget.device.id);
            final commandResponse = await widget.flutterReactiveBle
                .readCharacteristic(commandCharacteristic);
            if (commandResponse[0] == 0) {
              await widget.flutterReactiveBle.writeCharacteristicWithResponse(
                  commandCharacteristic,
                  value: [20, setpoint]);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
      content: SizedBox(
        height: 70.0,
        width: 300.0,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 16.0),
                  child: Slider(
                    value: setpoint.toDouble(),
                    onChanged: (newSetPoint) {
                      setpoint = (newSetPoint).floor();
                      setState(() {});
                    },
                    min: 0,
                    max: 100,
                    divisions: 20,
                  ),
                ),
                Text('$setpoint%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

///
class OzoneChangeSetpoint extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final int setpoint;
  const OzoneChangeSetpoint({
    super.key,
    required this.setpoint,
    required this.device,
    required this.flutterReactiveBle,
  });

  @override
  State<StatefulWidget> createState() {
    return _OzoneChangeSetpointState();
  }
}

class _OzoneChangeSetpointState extends State<OzoneChangeSetpoint> {
  int setpoint = 0;

  @override
  void initState() {
    setpoint = widget.setpoint;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Change Setpoint',
        textAlign: TextAlign.center,
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final commandCharacteristic = QualifiedCharacteristic(
                serviceId: cpuModuleServiceUuid,
                characteristicId: commandCharacteristicUuid,
                deviceId: widget.device.id);
            final commandResponse = await widget.flutterReactiveBle
                .readCharacteristic(commandCharacteristic);
            if (commandResponse[0] == 0) {
              await widget.flutterReactiveBle.writeCharacteristicWithResponse(
                  commandCharacteristic,
                  value: [21, setpoint]);
            }
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
      content: SizedBox(
        height: 70.0,
        width: 300.0,
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(trackHeight: 16.0),
                  child: Slider(
                    value: setpoint.toDouble(),
                    onChanged: (newSetPoint) {
                      setpoint = (newSetPoint).floor();
                      setState(() {});
                    },
                    min: 0,
                    max: 100,
                    divisions: 20,
                  ),
                ),
                Text('$setpoint%'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
