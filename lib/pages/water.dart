import 'package:flutter/material.dart';
import 'package:plant_monitor/bluetooth_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:plant_monitor/main.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyWater extends ConsumerStatefulWidget {
  final List<Plant> plantCard;
  const MyWater({super.key, required this.plantCard});

  @override
  ConsumerState<MyWater> createState() => _MyWaterState();
}

class _MyWaterState extends ConsumerState<MyWater> {
  PlantSensorData? plantSensor;
  int? pumpStatus; // or int pumpStatus = 0;
  int pump = 0;
  @override
  void initState() {
    super.initState();
    initializeSensor();
  }

  void initializeSensor() async {
    final db = ref.read(appDatabase);
    PlantSensorData data = await getSensor(
      db,
      widget.plantCard[0].id,
    );
    final int? status = await subscibeGetPumpStatus(
    BluetoothDevice.fromId(data.sensorId),
    db,
  );
    final int gotPumpStatus = status ?? 0; // <-- Default to 0 if null

  setState(() {
    plantSensor = data;
    pumpStatus = gotPumpStatus; // <-- Store as int
    pump = gotPumpStatus;
  });

  print('Pump status: $gotPumpStatus');

    
    
  }
  
  @override
  Widget build(BuildContext context) {
    // if (pumpStatus == null)
    // {
    //   int gotPumpStatus = 0;
    // }
    return Center(child: Text('my text for water container. This is the stat: $pump'));
  }
}

