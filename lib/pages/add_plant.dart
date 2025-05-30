import 'package:flutter/material.dart';
import 'package:plant_monitor/plant_data.dart';
import 'package:sqflite/sqflite.dart';

class AddPlant extends StatefulWidget {
  // TODO: figure out if there is a way not to define this function again..
  final void Function(
    Database database,
    String table,
    Map<String, Object> record,
  )
  onAddPlant;
  final Database database;
  AddPlant({super.key, required this.onAddPlant, required this.database});

  // plant data names
  final List<String> plantNames = [for (var plant in plants) plant.name];

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

  List<DropdownMenuEntry<String>> get menuItems =>
      widget.plantNames
          .map((name) => DropdownMenuEntry(value: name, label: name))
          .toList();

  int? _value = 0;
  String? _errorText;

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
            if (_controller.text.isNotEmpty) {
              widget.onAddPlant(widget.database, 'plants', {
                'name': _controller.text,
                'id': DateTime.now().millisecondsSinceEpoch,
              });
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
