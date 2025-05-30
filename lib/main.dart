import 'package:flutter/material.dart';
import 'package:plant_monitor/pages/statistics.dart';
import 'pages/home.dart';
import 'pages/water.dart';
import 'pages/add_plant.dart';
import 'data/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'data/plant.dart';

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

  // call database initializing
  late Future<Database> databasePlantKeeper;
  List<Plant> plantsCards = [];
  // update plantsCards to add existing cards in the db OR
  // use the database directly to show cards?
  // test cards
  // List<Plant> plantsCards = [
  //   // {'name': 'gummi', 'id': 0},
  //   // {'name': 'banan', 'id': 1},
  //   // {'name': 'test', 'id': 2},
  // ];
   @override
  void initState() {
    super.initState();
    databasePlantKeeper = initializeDatabase();

    // Load data from DB once ready
    databasePlantKeeper.then((db) async {
      List<Plant> loadedPlants = await allPlants(db);
      setState(() {
        plantsCards = loadedPlants;
      });
    });
  }
  
  // add a new plant card
  void _addPlant(
    Map<String, Object?> newPlant,
    Database database,
    String table,
    Map<String, Object> record,
  ) async {
    var testPlant = Plant(
      id: record["id"] as int,
      name: record["name"] as String,
      type: 'no type',
      waterNeedsMax: 0,
      waterNeedsMin: 0,
      sunLuxMax: 0,
      sunLuxMin: 0,
      humidityMax: 0,
      humidityMin: 0,
      airTempMax: 0,
      airTempMin: 0,
    );
    // call the database
    insertRecord(database, table, testPlant.toMap());
    
    print(await allPlants(database));

    setState(() {
      plantsCards.add(testPlant);
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
            builder:
                (context) => FutureBuilder<Database>(
                  future: databasePlantKeeper,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done &&
                        snapshot.hasData) {
                      return AddPlant(
                        onAddPlant: _addPlant,
                        database: snapshot.data!, // pass the actual database
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
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