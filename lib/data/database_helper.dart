import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
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

Future<void> updateRecord(
  Database database,
  String table,
  Map<String, Object> record,
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

Future<Database> initializeDatabase() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database and store the reference.
  final database = await openDatabase(
    join(await getDatabasesPath(), 'plantkeeper.db'),
    // When the database is first created, create a table to store plants.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
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
