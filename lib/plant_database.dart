import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// note: example model to get started

class Dog {
  final int id;
  final String name;
  final int age;

  const Dog({required this.id, required this.name, required this.age});

  // Convert a Dog into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'age': age};
  }

  // Implement toString to make it easier to see information about
  // each dog when using the print statement.
  @override
  String toString() {
    return 'Dog{id: $id, name: $name, age: $age}';
  }
}

// Define a function that inserts dogs into the database
Future<void> insertDog(Database database, Dog dog) async {
  final db = database;
  await db.insert(
    'dogs',
    dog.toMap(),
    conflictAlgorithm: ConflictAlgorithm.replace,
  );
}

// A method that retrieves all the dogs from the dogs table.
Future<List<Dog>> dogs(Database database) async {
  // Get a reference to the database.
  final db = database;
  // Query the table for all the dogs.
  final List<Map<String, Object?>> dogMaps = await db.query('dogs');

  // Convert the list of each dog's fields into a list of `Dog` objects.
  return [
    for (final {'id': id as int, 'name': name as String, 'age': age as int}
        in dogMaps)
      Dog(id: id, name: name, age: age),
  ];
}

Future<void> updateDog(Database database, Dog dog) async {
  // Get a reference to the database.
  final db = database;
  // Update the given Dog.
  await db.update('dogs', dog.toMap(), where: 'id = ?', whereArgs: [dog.id]);
}

Future<void> deleteDog(Database database, int id) async {
  // Get a reference to the database.
  final db = database;

  // Remove the Dog from the database.
  await db.delete(
    'dogs',
    // Use a `where` clause to delete a specific dog.
    where: 'id = ?',
    // Pass the Dog's id as a whereArg to prevent SQL injection.
    whereArgs: [id],
  );
}

void main() async {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();

  // Open the database and store the reference.
  final database = await openDatabase(
    join(await getDatabasesPath(), 'doggie_database.db'),
    onCreate: (db, version) {
      // Run the CREATE TABLE statement on the database.
      return db.execute(
        'CREATE TABLE dogs(id INTEGER PRIMARY KEY, name TEXT, age INTEGER)',
      );
    },
    version: 1,
  );

  // Create a Dog and add it to the dogs table
  // var fido = Dog(id: 0, name: 'Fido', age: 35);

  // await insertDog(database,fido);

  // var allDogs = await dogs(database);
  // var fido = allDogs.firstWhere(
  //   (dog) => dog.id == 0,
  //   orElse: () => Dog(id: 0, name: 'Fido', age: 35),
  // );

  final List<Map<String, Object?>> fidoQuery = await database.query(
    'dogs',
    columns: ['id', 'name', 'age'], // Query all needed columns
    where: 'id = ?',
    whereArgs: [0],
  );

  Dog? fido;
  if (fidoQuery.isNotEmpty) {
    final map = fidoQuery[0];

    fido = Dog(
      id: map['id'] as int,
      name: map['name'] as String,
      age: map['age'] as int,
    );
  } else {
    fido = null;
  }

  if (fido != null) {
    fido.toMap();
    // Now, use the method above to retrieve all the dogs.
    print(await dogs(database)); // Prints a list that include Fido.

    // Update Fido's age and save it to the database.
    fido = Dog(id: fido.id, name: fido.name, age: fido.age + 7);
    await updateDog(database, fido);
    // Print the updated results.
    print(await dogs(database)); // Prints Fido with age 42.
  }
  
}
