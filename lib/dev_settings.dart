import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/dev_info.dart';
import 'package:osv2/uuid_constants.dart';
import 'package:settings_ui/settings_ui.dart';

import 'dev_edit_device.dart';

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
            title: const Text('Developer'),
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
                          '${(uiInfoData[11] << 56) | (uiInfoData[10] << 48) | (uiInfoData[9] << 40) | (uiInfoData[8] << 32) | (uiInfoData[7] << 24) | (uiInfoData[6] << 16) | (uiInfoData[5] << 8) | (uiInfoData[4])}';
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
                          '${(chInfoData[15] << 88) | (chInfoData[14] << 80) | (chInfoData[13] << 72) | (chInfoData[12] << 64) | (chInfoData[11] << 56) | (chInfoData[10] << 48) | (chInfoData[9] << 40) | (chInfoData[8] << 32) | (chInfoData[7] << 24) | (chInfoData[6] << 16) | (chInfoData[5] << 8) | (chInfoData[4])}';
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
                          '${(ozInfoData[15] << 88) | (ozInfoData[14] << 80) | (ozInfoData[13] << 72) | (ozInfoData[12] << 64) | (ozInfoData[11] << 56) | (ozInfoData[10] << 48) | (ozInfoData[9] << 40) | (ozInfoData[8] << 32) | (ozInfoData[7] << 24) | (ozInfoData[6] << 16) | (ozInfoData[5] << 8) | (ozInfoData[4])}';
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
                          '${(prInfoData[15] << 88) | (prInfoData[14] << 80) | (prInfoData[13] << 72) | (prInfoData[12] << 64) | (prInfoData[11] << 56) | (prInfoData[10] << 48) | (prInfoData[9] << 40) | (prInfoData[8] << 32) | (prInfoData[7] << 24) | (prInfoData[6] << 16) | (prInfoData[5] << 8) | (prInfoData[4])}';
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
