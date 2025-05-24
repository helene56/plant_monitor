import 'package:flutter/material.dart';
import 'package:plant_monitor/pages/statistics.dart';
import 'pages/home.dart';
import 'pages/water.dart';
import 'pages/add_plant.dart';

void main() {
  runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPageindex = 1;

  // test cards
  List<Map<String, dynamic>> plantsCards = [
    {'label': 'gummi', 'plantId': 0},
    {'label': 'banan', 'plantId': 1},
    {'label': 'test', 'plantId': 2},
  ];
  // add a new plant card
  void _addPlant(Map<String, dynamic> newPlant) {
    setState(() {
      plantsCards.add(newPlant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      MyWater(),
      MyHome(plantsCards: plantsCards),
      MyStats(),
    ];
    return Scaffold(
      floatingActionButton: FloatingActionButton.small(
        onPressed: () {
          // Add your onPressed code here!
          showDialog(
            context: context,
            builder: (context) => AddPlant(onAddPlant: _addPlant),
          );
        },
        backgroundColor: Colors.lightGreen,
        shape: CircleBorder(),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(35),
            bottom: Radius.circular(35),
          ),
          child: NavigationBar(
            selectedIndex: currentPageindex,
            backgroundColor: Color.fromARGB(255, 250, 229, 212),
            indicatorColor: Color.fromARGB(255, 250, 229, 212),
            destinations: const <Widget>[
              NavigationDestination(
                selectedIcon: Icon(Icons.local_drink, color: Colors.blueAccent),
                icon: Icon(Icons.local_drink_outlined),
                label: 'Vand beholder',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.eco, color: Colors.green),
                icon: Icon(Icons.eco_outlined),
                label: 'Planter',
              ),
              NavigationDestination(
                selectedIcon: Icon(Icons.straighten, color: Colors.redAccent),
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
    );
  }
}
