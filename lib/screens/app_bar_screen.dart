import 'package:flutter/material.dart';
import 'package:osv2/screens/ozone_screen.dart';
import 'package:osv2/screens/probes_screen.dart';
import '../screens/home_screen.dart';
import '../utils/my_flutter_app_icons.dart';
import 'chlorinator_screen.dart';

class AppBarScreen extends StatelessWidget {
  const AppBarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        initialIndex: 0,
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Ozone Swim v2",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            bottom: const TabBar(
              tabs: <Widget>[
                Tab(
                  icon: Icon(Icons.home),
                ),
                Tab(
                  icon: Icon(CustomIcons.iconcl2),
                ),
                Tab(
                  icon: Icon(CustomIcons.icono3v2),
                ),
                Tab(
                  icon: Icon(Icons.remove_red_eye),
                ),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              HomeScreen(),
              ChlorinatorScreen(),
              OzoneScreen(),
              ProbesScreen(),
            ],
          ),
        ));
  }
}
