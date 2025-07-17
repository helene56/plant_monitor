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
import '../data/add_device_provider.dart';
import '/bluetooth/device_manager.dart';
import 'sensor_list.dart';

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
  int? selectedPlantId = 0;
  int? selectedContainerId;

  void _onSelectedContainerChanged(int? id) {
    setState(() {
      selectedContainerId = id;
    });
  }

  @override
  Widget build(BuildContext context) {
    // which sensor has been selected form SensorList
    final hasSensorSelected = ref.watch(
      deviceManagerProvider.select((state) => state.selectedIndex != null),
    );
    return AlertDialog(
      title: Text('Tilføj plante'),
      content: SingleChildScrollView(
        child: Column(
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
                  List<Widget>.generate(widget.plantingTypes.length, (
                    int index,
                  ) {
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
            // add availible sensors
            SensorList(),
            Text('Vand beholdere'),
            ExistingWaterContainers(
              onSelectedContainerChanged: _onSelectedContainerChanged,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_controller.text.isNotEmpty &&
                _value != null &&
                hasSensorSelected) {
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
              // if 'Ny' was selected, create new container
              // TODO: see if i can clean this logic up in the onpressed a bit..
              if (selectedContainerId == -1) {
                var newWaterContainer = WaterContainer(
                  id: DateTime.now().millisecondsSinceEpoch,
                  currentWaterLevel: 5,
                );
                insertRecord(
                  ref.read(appDatabase),
                  'containers',
                  newWaterContainer.toMap(),
                );
                selectedContainerId = newWaterContainer.id;
              } else if (selectedContainerId == null) {
                setState(() {
                  _errorText = 'Husk at vælge en beholder!';
                });
                return;
              }

              var newPlantWaterRelation = PlantContainer(
                plantId: newPlant.id,
                containerId: selectedContainerId!,
              );

              insertRecord(
                ref.read(appDatabase),
                'plant_containers',
                newPlantWaterRelation.toMap(),
              );
              // time to add sensor - TODO: is this necessary? maybe addSensor is enough
              ref.read(deviceManagerProvider.notifier).setTimeToAddSensor(true);
              // set plant id when adding sensor
              ref.read(deviceManagerProvider.notifier).addSensor(newPlant.id);
              Navigator.of(context).pop();
            } else if (_value == null) {
              setState(() {
                _errorText = 'Husk at vælge en plante type!';
              });
            } else if (!hasSensorSelected) {
              setState(() {
                _errorText = 'Ingen sensor valgt!';
                // ref.read(addPlantSensor.notifier).state = true;
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
            Navigator.of(context).pop();
          },
          child: Text('Luk'),
        ),
      ],
    );
  }
}

class ExistingWaterContainers extends ConsumerStatefulWidget {
  final ValueChanged<int?> onSelectedContainerChanged;
  const ExistingWaterContainers({
    super.key,
    required this.onSelectedContainerChanged,
  });

  @override
  ConsumerState<ExistingWaterContainers> createState() =>
      _ExistingWaterContainersState();
}

class _ExistingWaterContainersState
    extends ConsumerState<ExistingWaterContainers> {
  int numContainers = 0;
  List<PlantContainer> plantContainers = [];

  @override
  void initState() {
    super.initState();
    _loadNumContainers();
  }

  Future<void> _loadNumContainers() async {
    final containers = await allPlantContainers(ref.read(appDatabase));
    final uniqueByContainer =
        containers
            .fold<Map<int, PlantContainer>>({}, (map, item) {
              map[item.containerId] = item;
              return map;
            })
            .values
            .toList();
    setState(() {
      numContainers = uniqueByContainer.length;
      plantContainers = uniqueByContainer;
    });
  }

  int? selectedContainer;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 5.0,
      children: [
        // Standard option always shown first
        ChoiceChip(
          label: Text('Ny'),
          selected: selectedContainer == -1,
          onSelected: (bool selected) {
            setState(() {
              selectedContainer = selected ? -1 : selectedContainer;
              widget.onSelectedContainerChanged(selectedContainer);
            });
          },
        ),
        // Dynamically generated chips
        ...List<Widget>.generate(numContainers, (int index) {
          return ChoiceChip(
            label: Text('Beholder ${index + 1}'),
            selected: selectedContainer == index,
            onSelected: (bool selected) {
              setState(() {
                selectedContainer = selected ? index : null;
                widget.onSelectedContainerChanged(
                  plantContainers[index].containerId,
                );
              });
            },
          );
        }),
      ],
    );
  }
}
