import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:osv2/providers/ble_provider.dart';
import 'package:provider/provider.dart';
import '../utils/uuid_constants.dart';

final List<String> monthString = [
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

final List<String> dayOfWeekString = [
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
];

class Rtc with ChangeNotifier {
  DiscoveredDevice? device;
  FlutterReactiveBle flutterReactiveBle;

  Rtc(this.device, this.flutterReactiveBle);

  List<int> _rtcData = [0, 0, 0, 0, 0, 1, 0];
  String _rtcMonth = '';
  int _rtcDay = 0;
  String _rtcDayOfWeek = '';
  int _rtc24Hour = 0;
  int _rtc12Hour = 0;
  String _rtcAmPm = '';
  int _rtcMinutes = 0;
  StreamController _rtcController = StreamController();
  late ConnectedDevice _connectedDevice;

  String get rtcMonth => _rtcMonth;
  int get rtcDay => _rtcDay;
  String get rtcDayOfWeek => _rtcDayOfWeek;
  int get rtc24Hour => _rtc24Hour;
  int get rtc12Hour => _rtc12Hour;
  String get rtcAmPm => _rtcAmPm;
  int get rtcMinutes => _rtcMinutes;

  void initStream(BuildContext context) {
    _rtcController.addStream(
      flutterReactiveBle.subscribeToCharacteristic(
        QualifiedCharacteristic(
            characteristicId: rtcCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
            deviceId: device!.id),
      ),
    );
  }

  void initTime() async {
    _rtcData = await flutterReactiveBle.readCharacteristic(
        QualifiedCharacteristic(
            characteristicId: rtcCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
            deviceId: device!.id));
    _rtcMonth = monthString[_rtcData[5] - 1];
    _rtcDay = _rtcData[4];
    _rtcDayOfWeek = dayOfWeekString[_rtcData[3]];
    _rtc24Hour = _rtcData[2];
    _rtc12Hour = _rtc24Hour;
    _rtcAmPm = 'am';
    _rtcMinutes = _rtcData[1];
    if (_rtc24Hour == 0) {
      _rtc12Hour = 12;
      _rtcAmPm = 'am';
    } else if (_rtc24Hour < 13) {
      _rtc12Hour = _rtc24Hour;
      _rtcAmPm = 'am';
      if (_rtc12Hour == 12) {
        _rtcAmPm = 'pm';
      }
    } else {
      _rtc12Hour = _rtc24Hour - 12;
      _rtcAmPm = 'pm';
    }
    notifyListeners();
  }

  void computeTime() {
    _rtcController.stream.listen((content) {
      _rtcData = content;
      _rtcMonth = monthString[_rtcData[5] - 1];
      _rtcDay = _rtcData[4];
      _rtcDayOfWeek = dayOfWeekString[_rtcData[3]];
      _rtc24Hour = _rtcData[2];
      _rtc12Hour = _rtc24Hour;
      _rtcAmPm = 'am';
      _rtcMinutes = _rtcData[1];
      if (_rtc24Hour == 0) {
        _rtc12Hour = 12;
        _rtcAmPm = 'am';
      } else if (_rtc24Hour < 13) {
        _rtc12Hour = _rtc24Hour;
        _rtcAmPm = 'am';
        if (_rtc12Hour == 12) {
          _rtcAmPm = 'pm';
        }
      } else {
        _rtc12Hour = _rtc24Hour - 12;
        _rtcAmPm = 'pm';
      }
      notifyListeners();
    });
  }
}
