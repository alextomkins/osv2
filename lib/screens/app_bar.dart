import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../utils/my_flutter_app_icons.dart';

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
          body: TabBarView(
            children: [
              HomeScreen(),
              Chlorinator(),
              const Ozone(),
              const Probes(),
            ],
          ),
        ));
  }
}
