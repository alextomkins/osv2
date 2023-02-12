import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/main.dart';

class TurnOn extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;

  const TurnOn({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
  }) : super(key: key);

  @override
  State<TurnOn> createState() => _TurnOnState();
}

List<bool> isSelected = [true, false, false];

class _TurnOnState extends State<TurnOn> {
  @override
  Widget build(BuildContext context) {
    //Time

    print("object");
    StreamSubscription<List<int>> _timeStream;
    List<int> time_data = [];
    final Uuid CPUModuleServiceUuid =
        Uuid.parse('388a4ae7-f276-4321-b227-6cd344f0bb7d');
    final Uuid timeCharacteristicUuid =
        Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a02');
    final timeCharacteristic = QualifiedCharacteristic(
        serviceId: CPUModuleServiceUuid,
        characteristicId: timeCharacteristicUuid,
        deviceId: widget.device.id);

    widget.flutterReactiveBle
        .subscribeToCharacteristic(timeCharacteristic)
        .listen((data) {
      print(data);
    }, onError: (dynamic error) {
      print("error");
      // code to handle errors
    });

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
      body:
          Column(mainAxisAlignment: MainAxisAlignment.start, children: <Widget>[
        ElevatedButton(
            onPressed: () async {
              widget.flutterReactiveBle
                  .subscribeToCharacteristic(timeCharacteristic)
                  .listen((data) {
                print(data);
              }, onError: (dynamic error) {
                print("error");
                // code to handle errors
              });
            },
            child: const Text("test")),
        ElevatedButton(
          onPressed: () async {
            final Uuid serviceUuid =
                Uuid.parse('59462f12-9543-9999-12c8-58b459a2712d');
            final Uuid characteristicUuid =
                Uuid.parse('5c3a659e-897e-45e1-b016-007107c96df7');
            final characteristic = QualifiedCharacteristic(
                serviceId: serviceUuid,
                characteristicId: characteristicUuid,
                deviceId: widget.device.id);
            final response = await widget.flutterReactiveBle
                .readCharacteristic(characteristic);
            if (response[0] == 0) {
              await widget.flutterReactiveBle
                  .writeCharacteristicWithResponse(characteristic, value: [1]);
            } else {
              await widget.flutterReactiveBle
                  .writeCharacteristicWithResponse(characteristic, value: [0]);
            }
          },
          child: const Text('On/Off'),
        ),
        ToggleButtons(
          isSelected: isSelected,
          onPressed: (int index2) {
            setState(() {
              for (int buttonIndex = 0;
                  buttonIndex < isSelected.length;
                  buttonIndex++) {
                if (buttonIndex == index2) {
                  isSelected[buttonIndex] = true;
                } else {
                  isSelected[buttonIndex] = false;
                }
              }
            });
          },
          children: const <Widget>[
            Text("Off"),
            Text("Auto"),
            Text("On"),
          ],
        ),
      ]),
    );
  }
}
