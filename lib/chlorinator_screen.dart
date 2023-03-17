import 'package:flutter/material.dart';
import 'package:osv2/uuid_constants.dart';

TextStyle mainTitle =
    const TextStyle(color: Color.fromRGBO(53, 62, 71, 1), fontSize: 24.0);
TextStyle subTitles =
    const TextStyle(color: Color.fromRGBO(53, 62, 71, 1), fontSize: 18.0);
TextStyle values =
    const TextStyle(color: Color.fromRGBO(88, 201, 223, 1), fontSize: 12.0);
TextStyle valuesGreen = const TextStyle(color: Colors.green, fontSize: 12.0);
TextStyle valuesRed = const TextStyle(color: Colors.red, fontSize: 12.0);

class Chlorinator extends StatefulWidget {
  final int chAverageCurrent;
  final int chMaxCurrent;
  final int chSetPoint;
  final int chPeriod;
  final double chTemperature;
  final List<int> chStatusData;

  const Chlorinator({
    super.key,
    required this.chAverageCurrent,
    required this.chMaxCurrent,
    required this.chSetPoint,
    required this.chPeriod,
    required this.chTemperature,
    required this.chStatusData,
  });

  @override
  State<Chlorinator> createState() => _ChlorinatorState();
}

class _ChlorinatorState extends State<Chlorinator> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Chlorine Module',
          style: mainTitle,
          textAlign: TextAlign.center,
        ),
        Row(
          children: [
            Text(
              'Average Current',
              style: subTitles,
            ),
            Text(
              '${widget.chAverageCurrent} mA',
              style: values,
            ),
          ],
        ),
        Text(
          'Maximum Current',
          style: subTitles,
        ),
        Text(
          '${widget.chMaxCurrent} mA',
          style: values,
        ),
        Text(
          'Setpoint',
          style: subTitles,
        ),
        Text(
          '${widget.chSetPoint}',
          style: values,
        ),
        Text(
          'Period',
          style: subTitles,
        ),
        Text(
          '${widget.chPeriod}',
          style: values,
        ),
        Text(
          'Temperature',
          style: subTitles,
        ),
        Text(
          '${widget.chTemperature} \u2103',
          style: values,
        ),
        checkBit(widget.chStatusData[0], 0)
            ? Text(
                'Running',
                style: valuesGreen,
              )
            : Text(
                'Not Running',
                style: valuesRed,
              ),
        !checkBit(widget.chStatusData[0], 1)
            ? Text(
                'Water Detected',
                style: valuesGreen,
              )
            : Text(
                'No Water',
                style: valuesRed,
              ),
        !checkBit(widget.chStatusData[0], 2)
            ? Text(
                'Temperature Good',
                style: valuesGreen,
              )
            : Text(
                'Overheated',
                style: valuesRed,
              ),
        checkBit(widget.chStatusData[0], 3)
            ? Text(
                'Low Salt',
                style: valuesRed,
              )
            : checkBit(widget.chStatusData[0], 4)
                ? Text(
                    'High Salt',
                    style: valuesRed,
                  )
                : Text(
                    'Salt Level Good',
                    style: valuesGreen,
                  ),
        !checkBit(widget.chStatusData[0], 0)
            ? Text(
                'Current Detected',
                style: valuesGreen,
              )
            : Text(
                'No Current',
                style: valuesRed,
              ),
      ],
    ));
  }
}
