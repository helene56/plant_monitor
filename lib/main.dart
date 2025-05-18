import 'package:flutter/material.dart';
import 'package:plant_monitor/pages/statistics.dart';
import 'pages/home.dart';
import 'pages/water.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  int currentPageindex = 1;

  final List<Widget> widgetOptions = [
      MyWater(),
      MyHome(),
      MyStats()
    ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(35), bottom: Radius.circular(35)),
            child: NavigationBar(
              selectedIndex: currentPageindex,
              backgroundColor: Color.fromARGB(255, 250, 229, 212),
              indicatorColor: Color.fromARGB(255, 250, 229, 212),
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(Icons.water, color: Colors.blueAccent,),
                  icon: Icon(Icons.water),
                  label: 'water',
                ),
                NavigationDestination(
                  selectedIcon: Icon(Icons.eco, color: Colors.green,),
                  icon: Icon(Icons.eco_outlined),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: Badge(
                    label: Text('2'),
                    child: Icon(
                      Icons.messenger_sharp,
                    ),
                  ),
                  label: 'Messages',
                ),
              ],
              onDestinationSelected: (int index) {
                setState(() {
                  currentPageindex = index;
                });
              },
            ),
          ),
        ),
        backgroundColor: Color(0xfff6f9f8),
        body:  widgetOptions[currentPageindex],
      ),
    );
  }
}
