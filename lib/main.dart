import 'package:flutter/material.dart';
import 'package:osv2/util/utils.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'package:osv2/screens/scan_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((value) => runApp(const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OSv2',
      theme: ThemeData(
        textTheme: GoogleFonts.nunitoTextTheme(),
        primarySwatch: createMaterialColor(const Color(0xFF353E47)),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      //darkTheme: ThemeData.dark(),
      home: const ScanScreen(title: 'Ozone Swim v2'),
    );
  }
}
