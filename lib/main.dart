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
    MyStats(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        floatingActionButton:
            FloatingActionButton.small(
              onPressed: () {
                // Add your onPressed code here!
              },
              backgroundColor: Colors.lightGreen,
              shape: CircleBorder(),
              child: const Icon(Icons.add),
            ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(
            bottom: 8,
            left: 10,
            right: 10,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(35),
              bottom: Radius.circular(35),
            ),
            child: NavigationBar(
              selectedIndex: currentPageindex,
              backgroundColor: Color.fromARGB(
                255,
                250,
                229,
                212,
              ),
              indicatorColor: Color.fromARGB(
                255,
                250,
                229,
                212,
              ),
              destinations: const <Widget>[
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.local_drink,
                    color: Colors.blueAccent,
                  ),
                  icon: Icon(
                    Icons.local_drink_outlined,
                  ),
                  label: 'Vand beholder',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),
                  icon: Icon(Icons.eco_outlined),
                  label: 'Planter',
                ),
                NavigationDestination(
                  selectedIcon: Icon(
                    Icons.straighten,
                    color: Colors.redAccent,
                  ),
                  icon: Icon(Icons.straighten),
                  label: 'Statistik',
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
        body: widgetOptions[currentPageindex],
      ),
    );
  }
}
