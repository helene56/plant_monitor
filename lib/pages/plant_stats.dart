import 'package:flutter/material.dart';

class MyPlantStat extends StatelessWidget {
  final int plantId;
  const MyPlantStat({
    super.key,
    required this.plantId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 300,
                child: Image.asset(
                  './images/plant_test.png',
                ),
              ),
              Text('title', style: TextStyle(fontSize: 24),),
            ],
          ),
          Center(
            child: Text(
              'plant stats!!! id: $plantId',
            ),
          ),
        ],
      ),
    );
  }
}
