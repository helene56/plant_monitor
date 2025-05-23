import 'package:flutter/material.dart';

class AddPlant extends StatelessWidget {
  const AddPlant({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Tilføj plante'),
      content: Text('Her kan du tilføje en plante.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Luk'),
        ),
      ],
    );
  }
}
