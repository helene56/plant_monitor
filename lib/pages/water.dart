import 'package:flutter/material.dart';
import 'package:plant_monitor/bluetooth_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/database_helper.dart';
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
    initializeSensor();
  }

  void initializeSensor() async {
    List<int> newStatuses = [];
    final db = ref.read(appDatabase);
    // TODO: need to figure out how to store water container data..
    // should not index first element from plantCard
    List<PlantSensorData> allSensors = await getAllSensors(db);
    List<String> selectSensors = await getSelectedSensors(db, allSensors);
    // PlantSensorData data = await getSensor(db, widget.plantCards[0].id);
    for (var sensorId in selectSensors) {
      final int? status = await subscibeGetPumpStatus(
        BluetoothDevice.fromId(sensorId),
        db,
      );
      newStatuses.add(status!);
    }

    setState(() {
      statuses = newStatuses;
    });

    // maybe it should default to last known state from database?
    // final int gotPumpStatus = status ?? 0; // <-- Default to 0 if null

    // setState(() {
    //   plantSensor = data;
    //   pump = gotPumpStatus;
    // });

    // print('Pump status: $gotPumpStatus');
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: statuses.length,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            height: 50,
            color: Colors.amber,
            child: Center(
              child: Text(
                'my text for water container. This is the stat: ${statuses[index]}',
              ),
            ),
          );
        },
      ),
    );
  }
}


// Center(
//       child: Text('my text for water container. This is the stat: $pump'),
//     );