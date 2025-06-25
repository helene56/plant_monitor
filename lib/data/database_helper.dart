import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:plant_monitor/data/plant_container.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/water_container.dart';
import 'package:sqflite/sqflite.dart';
import 'plant.dart';
import 'plant_type.dart';

// functions

// Define a function that inserts plants into the database
Future<void> insertRecord(
  Database database,
  String table,
  Map<String, Object?> record,
) async {
  final db = database;
  await db.insert(table, record, conflictAlgorithm: ConflictAlgorithm.replace);
}

Future<List<PlantType>> plantTypes(Database database) async {
  // Get a reference to the database.
  final db = database;
  // Query the table for all the plants.
  final List<Map<String, Object?>> plantTypeMap = await db.query('plant_types');

  // Convert the list of each plant's fields into a list of `Plant` objects.
  return [
    for (final {
          'id': id as int,
          'label': label as String,
          'type': type as String,
          'waterNeedsMin': waterNeedsMin as int,
          'waterNeedsMax': waterNeedsMax as int,
          'sunLuxMin': sunLuxMin as int,
          'sunLuxMax': sunLuxMax as int,
          'airTempMin': airTempMin as int,
          'airTempMax': airTempMax as int,
          'humidityMin': humidityMin as int,
          'humidityMax': humidityMax as int,
        }
        in plantTypeMap)
      PlantType(
        id: id,
        label: label,
        type: type,
        waterNeedsMax: waterNeedsMax,
        waterNeedsMin: waterNeedsMin,
        sunLuxMax: sunLuxMax,
        sunLuxMin: sunLuxMin,
        airTempMax: airTempMax,
        airTempMin: airTempMin,
        humidityMax: humidityMax,
        humidityMin: humidityMin,
      ),
  ];
}

Future<PlantSensorData> getSensor(Database database, int id) async {
  // Get a reference to the database.
  final db = database;

  // Query plant sensor from the database.
  final List<Map<String, Object?>> plantSensorMap = await db.query(
    'plant_sensor',
    // Use a `where` clause to get a specific dog.
    where: 'id = ?',
    // Pass the plant sensor's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );

  return [
    for (var {
          'id': id as int,
          'sensorId': sensorId as String,
          'sensorName': sensorName as String,
          'water': water as int,
          'sunLux': sunLux as int,
          'airTemp': airTemp as int,
          'earthTemp': earthTemp as int,
          'humidity': humidity as int,
        }
        in plantSensorMap)
      PlantSensorData(
        id: id,
        sensorId: sensorId,
        sensorName: sensorName,
        water: water,
        sunLux: sunLux,
        airTemp: airTemp,
        earthTemp: earthTemp,
        humidity: humidity,
      ),
  ].first;
}

Future<List<String>> getSelectedSensors(
  Database database,
  List<PlantSensorData> sensors,
) async {
  final db = database;

  List<int> waterContainerId = [];
  List<String> selectedSensorsId = [];
  for (var sensor in sensors) {
    final List<Map<String, Object?>> plantContainerMap = await db.query(
      'plant_containers',
      where: 'plantId = ?',
      // Pass the plant sensor's id as a whereArg to prevent SQL injection.
      whereArgs: [sensor.id],
    );

    var plantContainers = [
      for (var {'plantId': id as int, 'containerId': containerId as int}
          in plantContainerMap)
        PlantContainer(plantId: id, containerId: containerId),
    ];
    // TODO: for now each plant get a container, at some point there should be 
    // an option to share a container between plants
    for (var plantContainer in plantContainers) {
      if (!waterContainerId.contains(plantContainer.containerId)) {
        waterContainerId.add(plantContainer.containerId);
        selectedSensorsId.add(sensor.sensorId);
      }
    }
  }

  return selectedSensorsId;
}


Future<List<WaterContainer>> getAllWaterContainers(Database database) async {
  // Get a reference to the database.
  final db = database;

  final List<Map<String, Object?>> waterContainerMap = await db.query(
    'containers',
  );

  return [
    for (var {
          'id': id as int,
          'currentWaterLevel': currentWaterLevel,
        }
        in waterContainerMap)
      WaterContainer(
        id: id,
        currentWaterLevel: (currentWaterLevel as double).toInt(),
      ),
  ];
}

Future<List<PlantContainer>> getAllPlantContainers(Database database) async {
  // Get a reference to the database.
  final db = database;

  final List<Map<String, Object?>> plantContainerMap = await db.query(
    'plant_containers',
  );

  return [
    for (var {
          'plantId': plantId as int,
          'containerId': containerId as int,
        }
        in plantContainerMap)
      PlantContainer(
        plantId: plantId,
        containerId: containerId,
      ),
  ];
}


Future<List<PlantSensorData>> getAllSensors(Database database) async {
  // Get a reference to the database.
  final db = database;

  // Query plant sensor from the database.
  final List<Map<String, Object?>> plantSensorMap = await db.query(
    'plant_sensor',
  );

  return [
    for (var {
          'id': id as int,
          'sensorId': sensorId as String,
          'sensorName': sensorName as String,
          'water': water as int,
          'sunLux': sunLux as int,
          'airTemp': airTemp as int,
          'earthTemp': earthTemp as int,
          'humidity': humidity as int,
        }
        in plantSensorMap)
      PlantSensorData(
        id: id,
        sensorId: sensorId,
        sensorName: sensorName,
        water: water,
        sunLux: sunLux,
        airTemp: airTemp,
        earthTemp: earthTemp,
        humidity: humidity,
      ),
  ];
}

// not sure yet I will need this..
// A method that retrieves all the plants from the plants table.
Future<List<Plant>> allPlants(Database database) async {
  // Get a reference to the database.
  final db = database;
  // Query the table for all the plants.
  final List<Map<String, Object?>> plantMap = await db.query('plants');

  // Convert the list of each plant's fields into a list of `Plant` objects.
  return [
    for (final {
          'id': id as int,
          'name': name as String,
          'type': type as String,
          'waterNeedsMin': waterNeedsMin as int,
          'waterNeedsMax': waterNeedsMax as int,
          'sunLuxMin': sunLuxMin as int,
          'sunLuxMax': sunLuxMax as int,
          'airTempMin': airTempMin as int,
          'airTempMax': airTempMax as int,
          'humidityMin': humidityMin as int,
          'humidityMax': humidityMax as int,
        }
        in plantMap)
      Plant(
        id: id,
        name: name,
        type: type,
        waterNeedsMax: waterNeedsMax,
        waterNeedsMin: waterNeedsMin,
        sunLuxMax: sunLuxMax,
        sunLuxMin: sunLuxMin,
        airTempMax: airTempMax,
        airTempMin: airTempMin,
        humidityMax: humidityMax,
        humidityMin: humidityMin,
      ),
  ];
}

Future<List<PlantContainer>> allPlantContainers(Database database) async {
  // Get a reference to the database.
  final db = database;
  // Query the table for all the plants.
  final List<Map<String, Object?>> plantMapContainers = await db.query('plant_containers');

  // Convert the list of each plant's fields into a list of `Plant` objects.
  return [
    for (final {
          'plantId': plantId as int,
          'containerId': containerId as int,
        }
        in plantMapContainers)
      PlantContainer(
        plantId: plantId,
        containerId: containerId,
      ),
  ];
}



Future<void> updateRecord(
  Database database,
  String table,
  Map<String, Object?> record,
) async {
  // Get a reference to the database.
  final db = database;
  // Update the given Dog.
  await db.update(table, record, where: 'id = ?', whereArgs: [record['id']]);
}

Future<void> deleteRecord(Database database, String table, int id) async {
  // Get a reference to the database.
  final db = database;

  // Remove the Dog from the database.
  await db.delete(
    table,
    // Use a `where` clause to delete a specific dog.
    where: 'id = ?',
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

Future<void> getLatestEntry(Database database, String table) async {
  final db = database;
  await db.query(table, orderBy: 'id DESC', limit: 1);
}

Future<Database> initializeDatabase() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // String sql = '''
  //   CREATE TABLE plants(
  //     id INTEGER PRIMARY KEY,
  //     name TEXT,
  //     type TEXT,
  //     waterNeedsMin INTEGER,
  //     waterNeedsMax INTEGER,
  //     sunLuxMin INTEGER,
  //     sunLuxMax INTEGER,
  //     airTempMin INTEGER,
  //     airTempMax INTEGER,
  //     humidityMin INTEGER,
  //     humidityMax INTEGER
  //   );
  //   CREATE TABLE plant_types(
  //     id INTEGER PRIMARY KEY,
  //     label TEXT,
  //     type TEXT,
  //     waterNeedsMin INTEGER,
  //     waterNeedsMax INTEGER,
  //     sunLuxMin INTEGER,
  //     sunLuxMax INTEGER,
  //     airTempMin INTEGER,
  //     airTempMax INTEGER,
  //     humidityMin INTEGER,
  //     humidityMax INTEGER
  //   );
  //   CREATE TABLE plant_sensor(
  //     id INTEGER PRIMARY KEY,
  //     sensorId TEXT,
  //     sensorName TEXT,
  //     water INTEGER,
  //     sunLux INTEGER,
  //     airTemp INTEGER,
  //     earthTemp INTEGER,
  //     humidity INTEGER
  //   );
  //   CREATE TABLE containers(
  //     id INTEGER PRIMARY KEY,
  //     current_water_level REAL,
  //   );
  //   CREATE TABLE plant_containers(
  //     id INTEGER PRIMARY KEY,
  //     plant_id INTEGER,
  //     container_id INTEGER,
  //     FOREIGN KEY (plant_id) REFERENCES plants (plant_id)
  //       ON UPDATE SET NULL
  //       ON DELETE SET NULL,
  //     FOREIGN KEY (container_id) REFERENCES containers (container_id)
  //       ON UPDATE SET NULL
  //       ON DELETE SET NULL,
  //   );
  // ''';

  // Open the database and store the reference.
  final database = await openDatabase(
    join(await getDatabasesPath(), 'plantkeeper.db'),
    // When the database is first created, create a table to store plants.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      // db.execute(sql);
      db.execute(
        'CREATE TABLE plants('
        'id INTEGER PRIMARY KEY, '
        'name TEXT, '
        'type TEXT, '
        'waterNeedsMin INTEGER, '
        'waterNeedsMax INTEGER, '
        'sunLuxMin INTEGER, '
        'sunLuxMax INTEGER, '
        'airTempMin INTEGER, '
        'airTempMax INTEGER, '
        'humidityMin INTEGER, '
        'humidityMax INTEGER'
        ')',
      );

      db.execute(
        'CREATE TABLE plant_types('
        'id INTEGER PRIMARY KEY,'
        'label TEXT,'
        'type TEXT, '
        'waterNeedsMin INTEGER, '
        'waterNeedsMax INTEGER, '
        'sunLuxMin INTEGER, '
        'sunLuxMax INTEGER, '
        'airTempMin INTEGER, '
        'airTempMax INTEGER, '
        'humidityMin INTEGER, '
        'humidityMax INTEGER'
        ')',
      );

      db.execute(
        'CREATE TABLE plant_sensor('
        'id INTEGER PRIMARY KEY,'
        'sensorId TEXT, '
        'sensorName TEXT, '
        'water INTEGER, '
        'sunLux INTEGER, '
        'airTemp INTEGER, '
        'earthTemp INTEGER, '
        'humidity INTEGER '
        ')',
      );

      // Add containers table
      db.execute(
        'CREATE TABLE containers('
        'id INTEGER PRIMARY KEY,'
        'currentWaterLevel REAL'
        ')',
      );

      // Add plant_containers table
      db.execute(
        'CREATE TABLE plant_containers('
        'id INTEGER PRIMARY KEY,'
        'plantId INTEGER,'
        'containerId INTEGER,'
        'FOREIGN KEY (plantId) REFERENCES plants(id) '
        'ON UPDATE SET NULL ON DELETE SET NULL,'
        'FOREIGN KEY (containerId) REFERENCES containers(id) '
        'ON UPDATE SET NULL ON DELETE SET NULL'
        ')',
      );
    },
    version: 1,
  );

  // create standard plant type options
  // TODO: in readme describe scala used
  // using 1-10 to define needs ranges for water.
  // ficus elastica has medium need for water..
  var ficus = PlantType(
    id: 0,
    label: 'Gummi træ',
    type: 'ficus elastica',
    waterNeedsMin: 4,
    waterNeedsMax: 6,
    sunLuxMin: 250,
    sunLuxMax: 1000,
    airTempMin: 18,
    airTempMax: 27,
    humidityMin: 50,
    humidityMax: 80,
  );

  // insert type, types, more to come?
  insertRecord(database, 'plant_types', ficus.toMap());

  return database;
}
