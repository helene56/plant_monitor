import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/pages/statistics.dart';
import 'pages/home.dart';
import 'pages/water.dart';
import 'pages/add_plant.dart';
import 'data/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'data/plant.dart';
import 'package:plant_monitor/data/plant_type.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../data/water_data_provider.dart';

Future<void> getSensorReadings(Database db, int plantId) async
{
  // read from sensor the saved values for how much water and temperate
  // insert into plant_history table

}


final appDatabase = Provider<Database>((ref) {
  throw UnimplementedError('Database provider was not initialized');
});

void main() async {
  // this is important to make sure flutter binding is initialized before runApp
  WidgetsFlutterBinding.ensureInitialized();
  // initialize database
  final db = await initializeDatabase();
 
  runApp(
    ProviderScope(
      overrides: [
      appDatabase.overrideWithValue(db),
    ],
      child: MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  int currentPageindex = 1;
  List<Plant> plantsCards = [];
  List<PlantType> plantingTypes = [];

  @override
  void initState() {
    super.initState();
    _initializeData(ref.read(appDatabase));
  }

  void _initializeData(Database db) async {
    final loadedPlants = await allPlants(db);
    final loadedPlantingTypes = await plantTypes(db);

    setState(() {
      plantsCards = loadedPlants;
      plantingTypes = loadedPlantingTypes;
    });
  }

  Future<void> _openDialog() async {
    final result = await showDialog(
      context: context,
      builder:
          (context) => AddPlant(
            onAddPlant: _addPlant,
            plantingTypes: plantingTypes,
          ),
    );
    // if dialog was dismissed by tapping outside
    if (result == null) {
      FlutterBluePlus.stopScan();
    }
    // Always refresh after dialog closes
    await ref.read(waterDataProvider.notifier).loadAll();
    
  }

  // add a new plant card
  void _addPlant(Database database, String table, Plant newPlant) async {
    // call the database
    insertRecord(database, table, newPlant.toMap());

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
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLandscape = orientation == Orientation.landscape;

        return Scaffold(
          floatingActionButton: Visibility(
            visible: !isLandscape, // The button is visible only in portrait mode
            child: FloatingActionButton.small(
              onPressed: () {
                _openDialog();
              },
              backgroundColor: Colors.lightGreen,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

          bottomNavigationBar: Visibility(
            visible: !isLandscape, // The navigation bar is visible only in portrait mode
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 10, right: 10),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(35),
                  bottom: Radius.circular(35),
                ),
                child: NavigationBar(
                  selectedIndex: currentPageindex,
                  backgroundColor: const Color.fromARGB(255, 250, 229, 212),
                  indicatorColor: const Color.fromARGB(255, 250, 229, 212),
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
          ),
          backgroundColor: const Color(0xfff6f9f8),
          body: widgetOptions[currentPageindex],
        );
      },
    );
  }
}