import 'package:flutter/material.dart';
import 'package:plant_monitor/bluetooth_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:plant_monitor/data/water_container.dart';
import 'package:plant_monitor/main.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class MyWater extends ConsumerStatefulWidget {
  final List<Plant> plantCards;
  const MyWater({super.key, required this.plantCards});

  @override
  ConsumerState<MyWater> createState() => _MyWaterState();
}

class _MyWaterState extends ConsumerState<MyWater> {
  PlantSensorData? plantSensor;
  List<int> statuses = [];

  int pump = 0;
  @override
  void initState() {
    super.initState();
    // TODO: should initalize first from database, then from program.
    // when connected of course this is maybe overwritten.
    initializeSensor();
  }

  void lastKnownPumpStatus() async {
    List<int> newStatuses = [];
    final db = ref.read(appDatabase);
    List<WaterContainer> waterContainers = await getAllWaterContainers(db);
    for (var container in waterContainers)
    {
      newStatuses.add(container.currentWaterLevel);
    }
    setState(() {
      statuses = newStatuses;
    });
  }


  void initializeSensor() async {
    List<int> newStatuses = [];
    final db = ref.read(appDatabase);
    
    List<PlantSensorData> allSensors = await getAllSensors(db);
    List<String> selectSensors = await getSelectedSensors(db, allSensors);
  
    for (var sensorId in selectSensors) {
      final int? status = await subscibeGetPumpStatus(
        BluetoothDevice.fromId(sensorId),
        db,
      );
      if (status == -1)
      {
        lastKnownPumpStatus();
        return;
      }
      newStatuses.add(status!);
    }

    setState(() {
      statuses = newStatuses;
    });

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: 300,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          itemCount: statuses.length,
          itemBuilder: (BuildContext context, int index) {
            int itemColorValue = 200 + (index * 200);
            // Clamp the value to the valid range for Colors.amber (100–900)
            itemColorValue = itemColorValue.clamp(100, 900);
        
            return Container(
              margin: EdgeInsets.all(10),
              height: 50,
              color: Colors.amber[itemColorValue],
              child: Center(
                child: Text(
                  'my text for water container. This is the stat: ${statuses[index]}',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}


// Center(
//       child: Text('my text for water container. This is the stat: $pump'),
//     );