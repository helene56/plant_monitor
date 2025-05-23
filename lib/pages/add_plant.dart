import 'package:flutter/material.dart';
import 'package:plant_monitor/plant_data.dart';

class AddPlant extends StatefulWidget {
  final void Function(Map<String, dynamic>) onAddPlant;
  AddPlant({super.key, required this.onAddPlant});


  // plant data names
  final List<String> plantNames = [for (var plant in plants) plant.name];

  @override
  State<AddPlant> createState() => _AddPlantState();
}

class _AddPlantState extends State<AddPlant> {
  List<DropdownMenuEntry<String>> get menuItems =>
      widget.plantNames
          .map((name) => DropdownMenuEntry(value: name, label: name))
          .toList();

  int? _value = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tilføj plante'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Her kan du tilføje en plante.'),
          SizedBox(
            child: TextField(
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
                List<Widget>.generate(widget.plantNames.length, (int index) {
                  return ChoiceChip(
                    label: Text(widget.plantNames[index]),
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
            widget.onAddPlant({
              'label': 'ny plante',
              'plantId': DateTime.now().millisecondsSinceEpoch,
            });
            Navigator.of(context).pop();
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
