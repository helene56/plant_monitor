import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// functions

// Define a function that inserts dogs into the database
Future<void> insertRecord(
  Database database,
  String table,
  Map<String, Object> record,
) async {
  final db = database;
  await db.insert(table, record, conflictAlgorithm: ConflictAlgorithm.replace);
}

// not sure yet I will need this..
// A method that retrieves all the dogs from the dogs table.
// Future<List<Dog>> dogs(Database database) async {
//   // Get a reference to the database.
//   final db = database;
//   // Query the table for all the dogs.
//   final List<Map<String, Object?>> dogMaps = await db.query('dogs');

//   // Convert the list of each dog's fields into a list of `Dog` objects.
//   return [
//     for (final {'id': id as int, 'name': name as String, 'age': age as int}
//         in dogMaps)
//       Dog(id: id, name: name, age: age),
//   ];
// }

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

void initializeDatabase() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database and store the reference.
  final database = await openDatabase(
    join(await getDatabasesPath(), 'plantkeeper.db'),
    // When the database is first created, create a table to store plants.
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
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
    },
    version: 1,
  );
}
