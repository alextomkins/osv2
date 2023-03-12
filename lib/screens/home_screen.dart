import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/rtc_provider.dart';
import '../utils/animations.dart';

bool checkBit(int value, int bit) => (value & (1 << bit)) != 0;

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SizedBox(height: 300, width: 300, child: RunningAnimation()),
          SizedBox(
            height: 300,
            width: 300,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  context.watch<Rtc>().rtcDayOfWeek,
                  style: const TextStyle(
                      fontSize: 30.0, color: Color.fromRGBO(53, 62, 71, 1)),
                ),
                Text(
                  '${context.watch<Rtc>().rtc12Hour}:${context.watch<Rtc>().rtcMinutes.toString().padLeft(2, '0')}${context.watch<Rtc>().rtcAmPm}',
                  style: const TextStyle(
                      fontSize: 60.0,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(53, 62, 71, 1)),
                ),
                Text(
                  '${context.watch<Rtc>().rtcDay} ${context.watch<Rtc>().rtcMonth}',
                  style: const TextStyle(
                      fontSize: 30.0, color: Color.fromRGBO(53, 62, 71, 1)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
