// import 'package:flutter/material.dart';

// class timer1 with ChangeNotifier {
//   double _timer1Progress = 0.0;
//   int _timer1StartHour = 0;
//   int _timer1Start24Hour = 0;
//   int _timer1Start12Hour = 0;
//   String _timer1StartAmPm = '';
//   int _timer1StartMinutes = 0;
//   int _timer1DurationTotal = 0;
//   int _timer1DurationHour = 0;
//   int _timer1DurationMinutes = 0;
//   int _timer1EndTotal = 0;
//   int _timer1End24Hour = 0;
//   int _timer1End12Hour = 0;
//   String _timer1EndAmPm = '';
//   int _timer1EndMinutes = 0;
//   int _timer1ElapsedMinutes = 0;
//   int _timer1StartTotalMinutes = 0;
//   List<int> _timersData = [];

//   double get timer1Progress => _timer1Progress;
//   int get timer1StartHour => _timer1StartHour;
//   int get timer1Start24Hour => _timer1Start24Hour;
//   int get timer1Start12Hour => _timer1Start12Hour;
//   String get timer1StartAmPm => _timer1StartAmPm;
//   int get timer1StartMinutes => _timer1StartMinutes;
//   int get timer1DurationTotal => _timer1DurationTotal;
//   int get timer1DurationHour => _timer1DurationHour;
//   int get timer1DurationMinutes => _timer1DurationMinutes;
//   int get timer1EndTotal => _timer1EndTotal;
//   int get timer1End24Hour => _timer1End24Hour;
//   int get timer1End12Hour => _timer1End12Hour;
//   String get timer1EndAmPm => _timer1EndAmPm;
//   int get timer1EndMinutes => _timer1EndMinutes;
//   int get timer1ElapsedMinutes => _timer1ElapsedMinutes;
//   int get timer1StartTotalMinutes => _timer1StartTotalMinutes;
//   List<int> get timersData => _timersData;

//   void initTimer1() {
//   _timersData = await flutterReactiveBle.readCharacteristic(
//                 QualifiedCharacteristic(
//                     characteristicId: timersCharacteristicUuid,
//                     serviceId: cpuModuleServiceUuid,
//                     deviceId: _foundBleUARTDevices[index].id));
// }
// }