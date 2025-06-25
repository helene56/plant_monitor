import 'package:flutter/material.dart';
import 'package:plant_monitor/bluetooth_helpers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:plant_monitor/data/water_container.dart';
import 'package:plant_monitor/main.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:math';

class MyWater extends ConsumerStatefulWidget {
  final List<Plant> plantCards;
  const MyWater({super.key, required this.plantCards});

  @override
  ConsumerState<MyWater> createState() => _MywaterFill();
}

class _MywaterFill extends ConsumerState<MyWater> {
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
    for (var container in waterContainers) {
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
      if (status == -1) {
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
        height: 697.4,
        child: ListView.builder(
          // scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(8),
          itemCount: statuses.length,
          itemBuilder: (BuildContext context, int index) {
            return Container(
              margin: EdgeInsets.all(15),
              child: Center(
                child: CustomCircleIcons(waterFill: statuses[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}

class CustomCircleIcons extends StatelessWidget {
  final int waterFill;
  const CustomCircleIcons({super.key, required this.waterFill});

  @override
  Widget build(BuildContext context) {
    // Configuration
    final double outerRadius = 100;
    final double iconRadius = 24;
    final double iconCircleRadius = outerRadius * 0.8;
    final List<IconData> icons = [
      Icons.home,
      Icons.favorite,
      Icons.settings,
      Icons.person,
      Icons.lightbulb,
      Icons.abc,
    ];

    return Center(
      child: SizedBox(
        width: outerRadius * 2,
        height: outerRadius * 2,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer circle visual (optional)
            Container(
              width: outerRadius * 2,
              height: outerRadius * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blue[50]!, width: 40),
              ),
            ),
            // Center icon
            Container(
              width: iconRadius * 2 * 2,
              height: iconRadius * 2 * 2,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black12)],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: CircularProgressIndicator(
                      value: waterFill / 100, // 50% fill
                      strokeWidth: 8,
                      backgroundColor: Colors.blue[50],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                    ),
                  ),
                  Icon(Icons.water_drop, size: 70, color: Colors.blue),
                  Positioned(
                    top: 30,
                    child: Text(
                      '$waterFill%',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Icons around the circle
            ...List.generate(icons.length, (i) {
              final double angle = (2 * pi / icons.length) * i;
              final double x = iconCircleRadius * cos(angle);
              final double y = iconCircleRadius * sin(angle);
              return Positioned(
                left: outerRadius + x - iconRadius,
                top: outerRadius + y - iconRadius,
                child: Container(
                  width: iconRadius * 2,
                  height: iconRadius * 2,
                  child: Tooltip(
                    message: 'hey',
                    triggerMode: TooltipTriggerMode.tap,
                    preferBelow: false,
                    child: Icon(icons[i], size: 28, color: Colors.blueAccent),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
