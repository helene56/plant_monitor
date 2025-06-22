import 'package:flutter/material.dart';
import 'package:plant_monitor/main.dart';

import 'package:sqflite/sqflite.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_type.dart';
import 'package:plant_monitor/bluetooth_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:plant_monitor/data/water_container.dart';
import 'package:plant_monitor/data/plant_container.dart';

class AddPlant extends ConsumerStatefulWidget {
  // TODO: figure out if there is a way not to define this function again..
  final void Function(Database database, String table, Plant newPlant)
  onAddPlant;
  final List<PlantType> plantingTypes;
  const AddPlant({
    super.key,
    required this.onAddPlant,
    required this.plantingTypes,
  });

  @override
  ConsumerState<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends ConsumerState<AddPlant> {
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
  int? selectedPlantId = 0;

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
            onAddDevice: addedPlant,
            exitAddPlant: exitAddPlant,
            currentPlantId: selectedPlantId!,
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
              widget.onAddPlant(ref.read(appDatabase), 'plants', newPlant);
              // insert current val of water from container
              // for now lets just initalize with 0
              var newWaterContainer = WaterContainer(id: DateTime.now().millisecondsSinceEpoch, currentWaterLevel: 0);
              var newPlantWaterRelation = PlantContainer(plantId: newPlant.id, containerId: newWaterContainer.id);
              insertRecord(ref.read(appDatabase), 'containers', newWaterContainer.toMap());
              insertRecord(ref.read(appDatabase), 'plant_containers', newPlantWaterRelation.toMap());
              // should add sensor device to database and also add autoconnect
              setState(() {
                selectedPlantId = newPlant.id;
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
