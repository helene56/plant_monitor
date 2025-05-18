import 'package:flutter/material.dart';

class MyPlantStat extends StatelessWidget {
  final int plantId;
  const MyPlantStat({super.key, required this.plantId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(child: Text('plant stats!!! id: $plantId')),
    );
  }
}
