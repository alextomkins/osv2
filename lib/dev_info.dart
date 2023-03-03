import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class DevInfo extends StatefulWidget {
  final DiscoveredDevice device;
  final FlutterReactiveBle flutterReactiveBle;
  final StreamSubscription<ConnectionStateUpdate>? connection;
  final List<int>? manufacturerNameData;
  final List<int>? modelNumberData;
  final List<int>? cpuDeviceInfoData;
  final List<int>? serielNumberData;
  final List<int>? hardwareRevisionData;
  final List<int>? firmwareRevisionData;
  final List<String> modulesInfo;

  const DevInfo({
    Key? key,
    required this.device,
    required this.flutterReactiveBle,
    required this.connection,
    required this.manufacturerNameData,
    required this.modelNumberData,
    required this.cpuDeviceInfoData,
    required this.serielNumberData,
    required this.hardwareRevisionData,
    required this.firmwareRevisionData,
    required this.modulesInfo,
  }) : super(key: key);

  @override
  State<DevInfo> createState() => _DevInfoState();
}

class _DevInfoState extends State<DevInfo> {
  List<int>? manufacturerNameData = [];
  List<int>? modelNumberData = [];
  List<int>? serielNumberData = [];
  List<int>? hardwareRevisionData = [];
  List<int>? firmwareRevisionData = [];
  List<int>? cpuDeviceInfoData = [0, 0];
  List<String> modulesInfo = ['', '', '', '', '', '', '', '', '', '', '', ''];
  String softwareRevision = '';
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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    modulesInfo = widget.modulesInfo;
    softwareRevision = packageInfo.version;
    manufacturerNameData = widget.manufacturerNameData;
    modelNumberData = widget.modelNumberData;
    cpuDeviceInfoData = widget.cpuDeviceInfoData;
    serielNumberData = widget.serielNumberData;
    hardwareRevisionData = widget.hardwareRevisionData;
    firmwareRevisionData = widget.firmwareRevisionData;
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
    String otherParameters =
        '''Manufacturer Name: ${String.fromCharCodes(manufacturerNameData!)}
Model Number: ${String.fromCharCodes(modelNumberData!)}
Serial Number: ${String.fromCharCodes(serielNumberData!)}
Hardware Revision: ${String.fromCharCodes(hardwareRevisionData!)}
Firmware Revision: ${String.fromCharCodes(firmwareRevisionData!)}
Software Revision: $softwareRevision
Transformer Size: ${transformerSize[cpuDeviceInfoData![0]]}
Cell Model: ${cellModel[cpuDeviceInfoData![1]]}
UI Module ID: ${modulesInfo[0]}
UI Module SW Version: ${modulesInfo[1]}
UI Module HW Version: ${modulesInfo[2]}
CH Module ID: ${modulesInfo[3]}
CH Module SW Version: ${modulesInfo[4]}
CH Module HW Version: ${modulesInfo[5]}
OZ Module ID: ${modulesInfo[6]}
OZ Module SW Version: ${modulesInfo[7]}
OZ Module HW Version: ${modulesInfo[8]}
Pr Module ID: ${modulesInfo[9]}
Pr Module SW Version: ${modulesInfo[10]}
Pr Module HW Version: ${modulesInfo[11]}''';
    return Scaffold(
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
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Other Parameters',
                          style: TextStyle(
                              fontSize: 25.0, fontWeight: FontWeight.bold)),
                    ),
                    Container(
                        margin: const EdgeInsets.all(15.0),
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromRGBO(53, 62, 71, 1)),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(otherParameters)),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: SizedBox(
                        width: 100.0,
                        height: 45.0,
                        child: ElevatedButton(
                          onPressed: () {
                            Share.share(otherParameters,
                                subject: 'Other Parameters');
                          },
                          child: const Text(
                            'Send',
                            style: TextStyle(
                                fontSize: 26.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
