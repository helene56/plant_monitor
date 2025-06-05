import 'package:flutter/material.dart';

import 'package:sqflite/sqflite.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_type.dart';
import 'package:plant_monitor/bluetooth_controller.dart';

class AddPlant extends StatefulWidget {
  // TODO: figure out if there is a way not to define this function again..
  final void Function(Database database, String table, Plant newPlant)
  onAddPlant;
  final Database database;
  final List<PlantType> plantingTypes;
  const AddPlant({
    super.key,
    required this.onAddPlant,
    required this.database,
    required this.plantingTypes,
  });

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

  int? _value = 0;
  String? _errorText;
  bool addedPlant = false;
  bool exitAddPlant = false;

  @override
  Widget build(BuildContext context) {
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
          Text('Plante type'),
          Wrap(
            spacing: 5.0,
            children:
                List<Widget>.generate(widget.plantingTypes.length, (int index) {
                  return ChoiceChip(
                    label: Text(widget.plantingTypes[index].label),
                    selected: _value == index,
                    onSelected: (bool selected) {
                      setState(() {
                        _value = selected ? index : null;
                      });
                    },
                  );
                }).toList(),
          ),
          Text('Sensor enheder'),
          MyBluetooth(
            database: widget.database,
            onAddDevice: addedPlant,
            exitAddPlant: exitAddPlant,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty && _value != null) {
              var newPlant = Plant(
                id: DateTime.now().millisecondsSinceEpoch,
                name: _controller.text,
                type:
                    widget
                        .plantingTypes[_value!]
                        .type, // this needs to be selected by the chip select
                waterNeedsMax: widget.plantingTypes[_value!].waterNeedsMax,
                waterNeedsMin: widget.plantingTypes[_value!].waterNeedsMin,
                sunLuxMax: widget.plantingTypes[_value!].sunLuxMax,
                sunLuxMin: widget.plantingTypes[_value!].sunLuxMin,
                humidityMax: widget.plantingTypes[_value!].humidityMax,
                humidityMin: widget.plantingTypes[_value!].humidityMin,
                airTempMax: widget.plantingTypes[_value!].airTempMax,
                airTempMin: widget.plantingTypes[_value!].airTempMin,
              );
              // add plant!!!
              widget.onAddPlant(widget.database, 'plants', newPlant);
              // should add sensor device to database and also add autoconnect
              setState(() {
                addedPlant = true;
                exitAddPlant = true;
              });
              Navigator.of(context).pop();
            } else if (_value == null) {
              setState(() {
                _errorText = 'Husk at vælge en plante type!';
              });
            } else {
              setState(() {
                _errorText = 'Feltet må ikke være tomt!';
              });
            }
          },
          child: Text('Tilføj'),
        ),
        TextButton(
          onPressed: () {
            setState(() {
              exitAddPlant = true;
            });
            Navigator.of(context).pop();
          },
          child: Text('Luk'),
        ),
      ],
    );
  }
}
