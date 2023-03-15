import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

import '../utils/uuid_constants.dart';

class Timer1 with ChangeNotifier {
  DiscoveredDevice? device;
  FlutterReactiveBle flutterReactiveBle;
  List<int> rtcData;

  Timer1(this.device, this.flutterReactiveBle, this.rtcData);

  double _timer1Progress = 0.0;
  int _timer1Start24Hour = 0;
  int _timer1Start12Hour = 0;
  String _timer1StartAmPm = '';
  int _timer1StartMinutes = 0;
  int _timer1DurationTotal = 0;
  int _timer1DurationHour = 0;
  int _timer1DurationMinutes = 0;
  int _timer1EndTotal = 0;
  int _timer1End24Hour = 0;
  int _timer1End12Hour = 0;
  String _timer1EndAmPm = '';
  int _timer1EndMinutes = 0;
  int _timer1ElapsedMinutes = 0;
  int _timer1StartTotalMinutes = 0;
  List<int> _timersData = [];
  final StreamController _timersController = StreamController();
  double _runTime = 0.0;
  int _rtcTotalMinutes = 0;

  double get runTime => _runTime;
  double get timer1Progress => _timer1Progress;
  int get timer1Start24Hour => _timer1Start24Hour;
  int get timer1Start12Hour => _timer1Start12Hour;
  String get timer1StartAmPm => _timer1StartAmPm;
  int get timer1StartMinutes => _timer1StartMinutes;
  int get timer1DurationTotal => _timer1DurationTotal;
  int get timer1DurationHour => _timer1DurationHour;
  int get timer1DurationMinutes => _timer1DurationMinutes;
  int get timer1EndTotal => _timer1EndTotal;
  int get timer1End24Hour => _timer1End24Hour;
  int get timer1End12Hour => _timer1End12Hour;
  String get timer1EndAmPm => _timer1EndAmPm;
  int get timer1EndMinutes => _timer1EndMinutes;
  int get timer1ElapsedMinutes => _timer1ElapsedMinutes;
  int get timer1StartTotalMinutes => _timer1StartTotalMinutes;
  List<int> get timersData => _timersData;

  void initStream(BuildContext context) {
    _timersController.addStream(
      flutterReactiveBle.subscribeToCharacteristic(
        QualifiedCharacteristic(
            characteristicId: timersCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
            deviceId: device!.id),
      ),
    );
  }

  // void readTimers(BuildContext context) async {
  //   _timersData = await flutterReactiveBle.readCharacteristic(
  //       QualifiedCharacteristic(
  //           characteristicId: timersCharacteristicUuid,
  //           serviceId: cpuModuleServiceUuid,
  //           deviceId: device!.id));
  // }

  void initTimers() async {
    _timersData = await flutterReactiveBle.readCharacteristic(
        QualifiedCharacteristic(
            characteristicId: timersCharacteristicUuid,
            serviceId: cpuModuleServiceUuid,
            deviceId: device!.id));
    _timer1Start24Hour = _timersData[0];
    if (_timer1Start24Hour == 0) {
      _timer1Start12Hour = 12;
      _timer1StartAmPm = 'am';
    } else if (_timer1Start24Hour < 13) {
      _timer1Start12Hour = _timer1Start24Hour;
      _timer1StartAmPm = 'am';
      if (_timer1Start12Hour == 12) {
        _timer1StartAmPm = 'pm';
      }
    } else {
      _timer1Start12Hour = _timer1Start24Hour - 12;
      _timer1StartAmPm = 'pm';
    }
    _timer1StartMinutes = _timersData[1];
    _timer1DurationTotal = (_timersData[2] << 8) | (_timersData[3]);
    _timer1DurationHour = (_timer1DurationTotal / 60).floor();
    _timer1DurationMinutes = _timer1DurationTotal % 60;
    _runTime = _timer1DurationTotal.toDouble();
    _timer1EndTotal =
        _timer1Start24Hour * 60 + _timer1StartMinutes + _timer1DurationTotal;
    if (_timer1EndTotal > 1440) {
      _timer1EndTotal -= 1440;
    }
    _timer1End24Hour = (_timer1EndTotal / 60).floor();
    if (_timer1End24Hour == 0) {
      _timer1End12Hour = 12;
      _timer1EndAmPm = 'am';
    } else if (_timer1End24Hour < 13) {
      _timer1End12Hour = _timer1End24Hour;
      _timer1EndAmPm = 'am';
      if (_timer1End12Hour == 12) {
        _timer1EndAmPm = 'pm';
      }
    } else {
      _timer1End12Hour = _timer1End24Hour - 12;
      _timer1EndAmPm = 'pm';
    }
    _timer1EndMinutes = _timer1EndTotal % 60;
    _rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
    _timer1StartTotalMinutes = _timer1Start24Hour * 60 + _timer1StartMinutes;
    if (_rtcTotalMinutes > _timer1StartTotalMinutes) {
      _timer1ElapsedMinutes = _rtcTotalMinutes - _timer1StartTotalMinutes;
    }
    if (_timer1ElapsedMinutes < _timer1DurationTotal) {
      _timer1Progress = _timer1ElapsedMinutes / _timer1DurationTotal;
    }
    notifyListeners();
  }

  void computeTimer1() {
    _timersController.stream.listen((content) {
      _timersData = content;
      _timer1Start24Hour = _timersData[0];
      if (_timer1Start24Hour == 0) {
        _timer1Start12Hour = 12;
        _timer1StartAmPm = 'am';
      } else if (_timer1Start24Hour < 13) {
        _timer1Start12Hour = _timer1Start24Hour;
        _timer1StartAmPm = 'am';
        if (_timer1Start12Hour == 12) {
          _timer1StartAmPm = 'pm';
        }
      } else {
        _timer1Start12Hour = _timer1Start24Hour - 12;
        _timer1StartAmPm = 'pm';
      }
      _timer1StartMinutes = _timersData[1];
      _timer1DurationTotal = (_timersData[2] << 8) | (_timersData[3]);
      _timer1DurationHour = (_timer1DurationTotal / 60).floor();
      _timer1DurationMinutes = _timer1DurationTotal % 60;
      _runTime = _timer1DurationTotal.toDouble();
      _timer1EndTotal =
          _timer1Start24Hour * 60 + _timer1StartMinutes + _timer1DurationTotal;
      if (_timer1EndTotal > 1440) {
        _timer1EndTotal -= 1440;
      }
      _timer1End24Hour = (_timer1EndTotal / 60).floor();
      if (_timer1End24Hour == 0) {
        _timer1End12Hour = 12;
        _timer1EndAmPm = 'am';
      } else if (_timer1End24Hour < 13) {
        _timer1End12Hour = _timer1End24Hour;
        _timer1EndAmPm = 'am';
        if (_timer1End12Hour == 12) {
          _timer1EndAmPm = 'pm';
        }
      } else {
        _timer1End12Hour = _timer1End24Hour - 12;
        _timer1EndAmPm = 'pm';
      }
      _timer1EndMinutes = _timer1EndTotal % 60;
      _rtcTotalMinutes = rtcData[1] + rtcData[2] * 60;
      _timer1StartTotalMinutes = _timer1Start24Hour * 60 + _timer1StartMinutes;
      if (_rtcTotalMinutes > _timer1StartTotalMinutes) {
        _timer1ElapsedMinutes = _rtcTotalMinutes - _timer1StartTotalMinutes;
      }
      if (_timer1ElapsedMinutes < _timer1DurationTotal) {
        _timer1Progress = _timer1ElapsedMinutes / _timer1DurationTotal;
      }
      notifyListeners();
    });
  }
}
