import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/screens/settings/dev/dev_info_screen.dart';
import 'package:osv2/util/uuid_constants.dart';
import 'package:settings_ui/settings_ui.dart';

import 'dev_edit_device_screen.dart';

class DevSettings extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? manufacturerNameData;
  final List<int>? modelNumberData;
  final List<int>? cpuDeviceInfoData;
  final List<int>? serielNumberData;

  const DevSettings({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.manufacturerNameData,
    required this.modelNumberData,
    required this.cpuDeviceInfoData,
    required this.serielNumberData,
  }) : super(key: key);

  @override
  State<DevSettings> createState() => _DevSettingsState();
}

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class _DevSettingsState extends State<DevSettings> {
  List<int>? manufacturerNameData = [];
  List<int>? modelNumberData = [];
  List<int>? serielNumberData = [];
  List<int>? hardwareRevisionData = [];
  List<int>? firmwareRevisionData = [];
  List<int>? cpuDeviceInfoData = [0, 0];
  List<int>? cpuStatusData = [0, 0];
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
    manufacturerNameData = widget.manufacturerNameData;
    modelNumberData = widget.modelNumberData;
    cpuDeviceInfoData = widget.cpuDeviceInfoData;
    serielNumberData = widget.serielNumberData;
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
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Developer Settings",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: const Text(
              'Developer',
              style: TextStyle(color: Color.fromRGBO(88, 201, 223, 1)),
            ),
            tiles: <SettingsTile>[
              SettingsTile.navigation(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Device'),
                description: Text(
                    'Transformer: ${transformerSize[cpuDeviceInfoData![0]]}, Cell Model: ${cellModel[cpuDeviceInfoData![1]]}, Model Number: ${String.fromCharCodes(modelNumberData!)}'),
                onPressed: (context) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditDevice(
                      device: widget.device,
                      flutterReactiveBle: widget.flutterReactiveBle,
                      connection: widget.connection,
                      modelNumberData: modelNumberData,
                      cpuDeviceInfoData: cpuDeviceInfoData,
                    ),
                  ),
                ),
              ),
              SettingsTile.navigation(
                  leading: const Icon(Icons.info),
                  title: const Text('Device Info'),
                  description: Text(
                      'Manufacturer Name: ${String.fromCharCodes(manufacturerNameData!)}, Serial Number: ${String.fromCharCodes(serielNumberData!)}'),
                  onPressed: (context) async {
                    cpuStatusData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId: cpuStatusCharacteristicUuid,
                            serviceId: cpuModuleServiceUuid,
                            deviceId: widget.device.id));
                    List<String> modulesInfo = [
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      '',
                      ''
                    ];
                    if (checkBit(cpuStatusData![0], 1)) {
                      final uiInfoData = await widget.flutterReactiveBle
                          .readCharacteristic(QualifiedCharacteristic(
                              characteristicId: uiDeviceInfoCharacteristicUuid,
                              serviceId: modbusDeviceInfoServiceUuid,
                              deviceId: widget.device.id));
                      modulesInfo[0] =
                          '${(uiInfoData[0] << 8) | (uiInfoData[1])}';
                      modulesInfo[1] =
                          '${(uiInfoData[2] << 8) | (uiInfoData[3])}';
                      modulesInfo[2] =
                          '${uiInfoData[4].toRadixString(16).padLeft(2, '0')}:'
                          '${uiInfoData[5].toRadixString(16).padLeft(2, '0')}:'
                          '${uiInfoData[6].toRadixString(16).padLeft(2, '0')}:'
                          '${uiInfoData[7].toRadixString(16).padLeft(2, '0')}:'
                          '${uiInfoData[8].toRadixString(16).padLeft(2, '0')}:'
                          '${uiInfoData[9].toRadixString(16).padLeft(2, '0')}';
                      modulesInfo[2] = modulesInfo[2].toUpperCase();
                    }
                    if (checkBit(cpuStatusData![0], 2)) {
                      final chInfoData = await widget.flutterReactiveBle
                          .readCharacteristic(QualifiedCharacteristic(
                              characteristicId: chDeviceInfoCharacteristicUuid,
                              serviceId: modbusDeviceInfoServiceUuid,
                              deviceId: widget.device.id));
                      modulesInfo[3] =
                          '${(chInfoData[0] << 8) | (chInfoData[1])}';
                      modulesInfo[4] =
                          '${(chInfoData[2] << 8) | (chInfoData[3])}';
                      modulesInfo[5] =
                          '${chInfoData[4]}${chInfoData[5]}-${chInfoData[6]}${chInfoData[7]}-${chInfoData[8]}${chInfoData[9]}-${chInfoData[10]}${chInfoData[11]}-${chInfoData[12]}${chInfoData[13]}-${chInfoData[14]}${chInfoData[15]}';
                    }
                    if (checkBit(cpuStatusData![0], 3)) {
                      final ozInfoData = await widget.flutterReactiveBle
                          .readCharacteristic(QualifiedCharacteristic(
                              characteristicId: ozDeviceInfoCharacteristicUuid,
                              serviceId: modbusDeviceInfoServiceUuid,
                              deviceId: widget.device.id));
                      modulesInfo[6] =
                          '${(ozInfoData[0] << 8) | (ozInfoData[1])}';
                      modulesInfo[7] =
                          '${(ozInfoData[2] << 8) | (ozInfoData[3])}';
                      modulesInfo[8] =
                          '${ozInfoData[4]}${ozInfoData[5]}-${ozInfoData[6]}${ozInfoData[7]}-${ozInfoData[8]}${ozInfoData[9]}-${ozInfoData[10]}${ozInfoData[11]}-${ozInfoData[12]}${ozInfoData[13]}-${ozInfoData[14]}${ozInfoData[15]}';
                    }
                    if (checkBit(cpuStatusData![1], 1)) {
                      final prInfoData = await widget.flutterReactiveBle
                          .readCharacteristic(QualifiedCharacteristic(
                              characteristicId: prDeviceInfoCharacteristicUuid,
                              serviceId: modbusDeviceInfoServiceUuid,
                              deviceId: widget.device.id));
                      modulesInfo[9] =
                          '${(prInfoData[0] << 8) | (prInfoData[1])}';
                      modulesInfo[10] =
                          '${(prInfoData[2] << 8) | (prInfoData[3])}';
                      modulesInfo[11] =
                          '${prInfoData[4]}${prInfoData[5]}-${prInfoData[6]}${prInfoData[7]}-${prInfoData[8]}${prInfoData[9]}-${prInfoData[10]}${prInfoData[11]}-${prInfoData[12]}${prInfoData[13]}-${prInfoData[14]}${prInfoData[15]}';
                    }
                    hardwareRevisionData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId:
                                hardwareRevisionCharacteristicUuid,
                            serviceId: deviceInformationServiceUuid,
                            deviceId: widget.device.id));
                    firmwareRevisionData = await widget.flutterReactiveBle
                        .readCharacteristic(QualifiedCharacteristic(
                            characteristicId:
                                firmwareRevisionCharacteristicUuid,
                            serviceId: deviceInformationServiceUuid,
                            deviceId: widget.device.id));
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DevInfo(
                          device: widget.device,
                          flutterReactiveBle: widget.flutterReactiveBle,
                          connection: widget.connection,
                          manufacturerNameData: manufacturerNameData,
                          serielNumberData: serielNumberData,
                          hardwareRevisionData: hardwareRevisionData,
                          firmwareRevisionData: firmwareRevisionData,
                          modelNumberData: modelNumberData,
                          cpuDeviceInfoData: cpuDeviceInfoData,
                          modulesInfo: modulesInfo,
                        ),
                      ),
                    );
                  }),
            ],
          ),
        ],
      ),
    );
  }
}
