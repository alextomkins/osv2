import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class DevSettings extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? modelNumberData;
  final List<int>? cpuDeviceInfoData;

  const DevSettings({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.modelNumberData,
    required this.cpuDeviceInfoData,
  }) : super(key: key);

  @override
  State<DevSettings> createState() => _DevSettingsState();
}

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class _DevSettingsState extends State<DevSettings> {
  final Uuid cpuModuleServiceUuid =
      Uuid.parse('388a4ae7-f276-4321-b227-6cd344f0bb7d');

  final Uuid commandCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a06');
  final Uuid cpuDeviceInfoCharacteristicUuid =
      Uuid.parse('6e884d38-1559-4fed-beb6-2c2166df9a04');

  List<int>? modelNumberData = [];
  List<int>? cpuDeviceInfoData = [0, 0];
  String softwareRevision = '';
  String? transformerSizeValue;
  String? cellModelValue;
  TextEditingController? textController;
  final transformerSize = [
    '250VA / 240v',
    '400VA / 240v',
    '600VA / 240v',
    '250VA / 120v',
    '400VA / 120v',
    '600VA / 120v',
  ];
  final cellModel = [
    '30kL',
    '60kL',
    '80kL',
    '90kL',
    '100kL',
    '120kL',
    '140kL',
    '160kL',
  ];

  Future<void> _initData() async {
    modelNumberData = widget.modelNumberData;
    cpuDeviceInfoData = widget.cpuDeviceInfoData;
    transformerSizeValue = transformerSize[cpuDeviceInfoData![0]];
    cellModelValue = cellModel[cpuDeviceInfoData![1]];
    textController =
        TextEditingController(text: String.fromCharCodes(modelNumberData!));
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    setState(() {});
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "Device Info",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        body: Center(
          child: Column(
            children: [
              DefaultTextStyle(
                style: const TextStyle(
                    fontSize: 18.0, color: Color.fromRGBO(53, 62, 71, 1)),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Settings',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text('Device ID'),
                    Container(
                      width: 250,
                      margin: const EdgeInsets.all(2.0),
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: TextField(
                        controller: textController,
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(88, 201, 223, 1),
                                  width: 4.0),
                              borderRadius: BorderRadius.circular(12.0)),
                          focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  color: Color.fromRGBO(88, 201, 223, 1),
                                  width: 4.0),
                              borderRadius: BorderRadius.circular(12.0)),
                        ),
                      ),
                    ),
                    const Text('Transformer Size'),
                    Container(
                      width: 250,
                      margin: const EdgeInsets.all(2.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: const Color.fromRGBO(88, 201, 223, 1),
                            width: 4.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: transformerSizeValue,
                          items: transformerSize.map(buildMenuItem).toList(),
                          onChanged: (value) => setState(() {
                            transformerSizeValue = value;
                          }),
                        ),
                      ),
                    ),
                    const Text('Cell Model'),
                    Container(
                      width: 250,
                      margin: const EdgeInsets.all(2.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(
                            color: const Color.fromRGBO(88, 201, 223, 1),
                            width: 4.0),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: cellModelValue,
                          items: cellModel.map(buildMenuItem).toList(),
                          onChanged: (value) => setState(() {
                            cellModelValue = value;
                          }),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 100.0,
                      height: 45.0,
                      child: ElevatedButton(
                          onPressed: () async {
                            final commandCharacteristic =
                                QualifiedCharacteristic(
                                    serviceId: cpuModuleServiceUuid,
                                    characteristicId: commandCharacteristicUuid,
                                    deviceId: widget.device.id);
                            var commandResponse = await widget
                                .flutterReactiveBle
                                .readCharacteristic(commandCharacteristic);
                            if (commandResponse[0] == 0) {
                              await widget.flutterReactiveBle
                                  .writeCharacteristicWithResponse(
                                      commandCharacteristic,
                                      value: [
                                    240,
                                    transformerSize
                                        .indexOf(transformerSizeValue!)
                                  ]);
                            }
                            commandResponse = await widget.flutterReactiveBle
                                .readCharacteristic(commandCharacteristic);
                            if (commandResponse[0] == 0) {
                              await widget.flutterReactiveBle
                                  .writeCharacteristicWithResponse(
                                      commandCharacteristic,
                                      value: [
                                    241,
                                    cellModel.indexOf(cellModelValue!)
                                  ]);
                            }
                            await Future.delayed(const Duration(seconds: 1));
                            cpuDeviceInfoData = await widget.flutterReactiveBle
                                .readCharacteristic(QualifiedCharacteristic(
                                    characteristicId:
                                        cpuDeviceInfoCharacteristicUuid,
                                    serviceId: cpuModuleServiceUuid,
                                    deviceId: widget.device.id));
                            setState(() {});
                          },
                          child: const Text('Save',
                              style: TextStyle(
                                  fontSize: 26.0,
                                  fontWeight: FontWeight.bold))),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  DropdownMenuItem<String> buildMenuItem(String item) =>
      DropdownMenuItem(value: item, child: Text(item));
}
