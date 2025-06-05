import 'package:flutter/material.dart';
import 'package:plant_monitor/pages/statistics.dart';
import 'pages/home.dart';
import 'pages/water.dart';
import 'pages/add_plant.dart';
import 'data/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'data/plant.dart';
import 'data/plant_sensor_data.dart';
import 'package:plant_monitor/data/plant_type.dart';

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
  List<PlantType> plantingTypes = [];

  @override
  void initState() {
    super.initState();
    databasePlantKeeper = initializeDatabase();

    // Load data from DB once ready
    databasePlantKeeper.then((db) async {
      List<Plant> loadedPlants = await allPlants(db);
      List<PlantType> loadedPlantingTypes = await plantTypes(db);
      setState(() {
        plantsCards = loadedPlants;
        plantingTypes = loadedPlantingTypes;
      });
    });
  }


//   void onAddDevice() {
//   print("Device added callback triggered!");
//   // You can update state or reload something here later
// }

  // add a new plant card
  void _addPlant(Database database, String table, Plant newPlant) async {
    // call the database
    insertRecord(database, table, newPlant.toMap());
    // insert sensor values
    // initialize values as 0 -> maybe later i can add values from sensor if connected
    var sensor = PlantSensorData(
      id: newPlant.id,
      water: 0,
      sunLux: 0,
      airTemp: 0,
      earthTemp: 0,
      humidity: 0,
    );
    insertRecord(database, 'plant_sensor', sensor.toMap());

    print(await allPlants(database));

    setState(() {
      plantsCards.add(newPlant);
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = [
      MyWater(),
      // pass database to myhome, so availible for delete calls as well
      FutureBuilder(
        future: databasePlantKeeper,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return MyHome(plantsCards: plantsCards, database: snapshot.data!);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
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
                        plantingTypes: plantingTypes,
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
