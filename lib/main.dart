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
import 'bluetooth_helpers.dart';
import 'package:flutter/foundation.dart';
import 'bluetooth/bt_uuid.dart';
import '/bluetooth/device_manager.dart';

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
      overrides: [appDatabase.overrideWithValue(db)],
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
  bool loadedLogs = false;

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
          (context) =>
              AddPlant(onAddPlant: _addPlant, plantingTypes: plantingTypes),
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
    if (!loadedLogs) {
      final allDevices = ref.watch(
        deviceManagerProvider.select((state) => state.allDevices),
      );
      for (var device in allDevices) {
        getSensorReadings(
          ref.read(appDatabase),
          0,
          BluetoothDevice.fromId(device.deviceId),
        );
      }

      // loadedLogs = true;
    }

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
            visible:
                !isLandscape, // The button is visible only in portrait mode
            child: FloatingActionButton.small(
              onPressed: () {
                _openDialog();
              },
              backgroundColor: Colors.lightGreen,
              shape: const CircleBorder(),
              child: const Icon(Icons.add),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,

          bottomNavigationBar: Visibility(
            visible:
                !isLandscape, // The navigation bar is visible only in portrait mode
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
                      selectedIcon: Icon(
                        Icons.local_drink,
                        color: Colors.blueAccent,
                      ),
                      icon: Icon(Icons.local_drink_outlined),
                      label: 'Vand beholder',
                    ),
                    NavigationDestination(
                      selectedIcon: Icon(Icons.eco, color: Colors.green),
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
          ),
          backgroundColor: const Color(0xfff6f9f8),
          body: widgetOptions[currentPageindex],
        );
      },
    );
  }
}

Future<void> getSensorReadings(
  Database db,
  int plantId,
  BluetoothDevice device,
) async {
  // TODO: add data related to plant
  // Ensure device is connected
  if (device.isDisconnected) {
    await autoConnectDevice(db); // make sure this awaits the connection
  }

  // Wait until device reports it is connected
  await device.connectionState.firstWhere(
    (state) => state == BluetoothConnectionState.connected,
  );

  // Now we are sure device is connected
  if (kDebugMode) {
    debugPrint('Device is connected');
  }

  try {
    final services = await device.discoverServices();

    final targetService = services.firstWhere(
      (s) => s.serviceUuid.toString() == BtUuid.serviceId,
      orElse: () => throw Exception("Service not found"),
    );

    final targetChar = targetService.characteristics.firstWhere(
      (c) => c.uuid.toString() == BtUuid.sensorLogCharId,
      orElse: () => throw Exception("Characteristic not found"),
    );

    final value = await targetChar.read();

    if (kDebugMode) {
      debugPrint("Received log values: $value");
      final buffer = value;

      final year = buffer[0] | (buffer[1] << 8);
      final month = buffer[2];
      final day = buffer[3];
      final val1 = buffer[4];
      final val2 = buffer[5];

      debugPrint("Date: ${year}/${month}/${day}");
      debugPrint("random val 1: ${val1}");
      debugPrint("random val 2: ${val2}");
      // here i should set it not to read anymore?

    }
  } catch (e) {
    if (kDebugMode) {
      debugPrint("Error: $e");
    }
    return; // return error code
  }
}
