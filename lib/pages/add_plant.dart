import 'package:flutter/material.dart';
// import 'package:plant_monitor/plant_data.dart';
import 'package:sqflite/sqflite.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_type.dart';
import 'package:plant_monitor/data/database_helper.dart';

class AddPlant extends StatefulWidget {
  // TODO: figure out if there is a way not to define this function again..
  final void Function(
    Database database,
    String table,
    Plant newPlant,
  )
  onAddPlant;
  final Database database;
  AddPlant({super.key, required this.onAddPlant, required this.database});

  // plant data names -> should use types in the database!!
  // final List<String> plantNames = [for (var plant in plants) plant.name];

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> {
  // controller for text input
  final TextEditingController _controller = TextEditingController();
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  // List<DropdownMenuEntry<String>> get menuItems =>
  //     widget.plantNames
  //         .map((name) => DropdownMenuEntry(value: name, label: name))
  //         .toList();

  int? _value = 0;
  String? _errorText;
  List<PlantType>? plantingTypes;

  @override
  void initState() {
    super.initState();
    // load the plant type object stored in database
    // maybe this is ok, for the types statically defined..
    // plantingTypes = plantTypes(widget.database);
    loadPlantingTypes();
  }

  void loadPlantingTypes() async {
    List<PlantType> types = await plantTypes(widget.database);
    setState(() {
      plantingTypes = types;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (plantingTypes == null) {
    return const CircularProgressIndicator(); // or a placeholder
  }
  // now safe to use plantingTypes
  // just temp for now, might replace with something else...
    return AlertDialog(
      title: Text('Tilføj plante'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Her kan du tilføje en plante.'),
          if (_errorText != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(_errorText!, style: TextStyle(color: Colors.red)),
            ),
          SizedBox(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'plante navn',
              ),
            ),
          ),
          SizedBox(height: 20),
          Text('plante type'),
          Wrap(
            spacing: 5.0,
            children:
                List<Widget>.generate(plantingTypes!.length, (int index) {
                  return ChoiceChip(
                    label: Text(plantingTypes![index].label),
                    selected: _value == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _value = selected ? index : null;
                      });
                    },
                  );
                }).toList(),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty && plantingTypes != null && _value != null) {
              // TODO: maybe check if _value is not null..
              final types = plantingTypes!;
              var newPlant = Plant(
                id: DateTime.now().millisecondsSinceEpoch,
                name: _controller.text,
                type: types[_value!].type, // this needs to be selected by the chip select
                waterNeedsMax: types[_value!].waterNeedsMax,
                waterNeedsMin: types[_value!].waterNeedsMin,
                sunLuxMax: types[_value!].sunLuxMax,
                sunLuxMin: types[_value!].sunLuxMin,
                humidityMax: types[_value!].humidityMax,
                humidityMin: types[_value!].humidityMin,
                airTempMax: types[_value!].airTempMax,
                airTempMin: types[_value!].airTempMin,
              );
              // add plant!!!
              widget.onAddPlant(widget.database, 'plants', newPlant);
              Navigator.of(context).pop();
            } else {
              setState(() {
                _errorText = 'Feltet må ikke være tomt!';
              });
            }
          },
          child: Text('Tilføj'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Luk'),
        ),
      ],
    );
  }
}
