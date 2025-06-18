import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/main.dart';
// import 'package:sqflite/sqflite.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyPlantStat extends ConsumerStatefulWidget {
  final int plantId;
  final Plant plantCard;
  const MyPlantStat({
    super.key,
    required this.plantId,
    required this.plantCard,
  });

  @override
  ConsumerState<MyPlantStat> createState() => _MyPlantStatState();
}

class _MyPlantStatState extends ConsumerState<MyPlantStat> {
  bool showingToolTips = false;
  PlantSensorData? plantSensor;
  StreamSubscription? _bluetoothSubscription;
  @override
  void initState() {
    super.initState();
    initializeSensor();
  }

  void initializeSensor() async {
    PlantSensorData data = await getSensor(
      ref.read(appDatabase),
      widget.plantCard.id,
    );
    setState(() {
      plantSensor = data;
    });
    subscibeToDevice(BluetoothDevice.fromId(plantSensor!.sensorId));
  }

  Future<void> autoConnectDevice() async {
    // if getSensor is not empty
    // autoconnect device and add to devices
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    List<PlantSensorData> sensors = await getSensors(ref.read(appDatabase));
    for (var sensor in sensors) {
      var device = BluetoothDevice.fromId(sensor.sensorId);
      await device.connect(autoConnect: true, mtu: null).then((_) {});

      await device.connectionState.firstWhere(
        (state) => state == BluetoothConnectionState.connected,
      );
    }
  }

  Future<void> subscibeToDevice(BluetoothDevice device) async {
    if (device.isDisconnected) {
      // Connect to the device
      await autoConnectDevice();
    }

    device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        print('Device is connected');
        List<BluetoothService> services = await device.discoverServices();
        for (var service in services) {
          if (service.serviceUuid.toString() ==
              "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
            for (var c in service.characteristics) {
              if (c.uuid.toString() == "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
                // Enable notifications
                await c.setNotifyValue(true);
                // Listen for value changes
                final bluetoothSubscription = c.onValueReceived.listen((
                  value,
                ) async {
                  if (!mounted) return; // Check if the widget is still mounted
                  if (plantSensor == null) {
                    // Still not ready, so skip this update
                    return;
                  }
                  // update plantsensor -- should update database
                  if (mounted) {
                    setState(() {
                      plantSensor = plantSensor!.copyWith(airTemp: value[0]);
                    });
                  }

                  // Update the database (async, outside of setState)
                  await updateRecord(
                    ref.read(appDatabase),
                    'plant_sensor',
                    plantSensor!.toMap(),
                  );

                  print('Sensor data: $value');
                });
                // Automatically cancel subscription when device disconnects
                device.cancelWhenDisconnected(bluetoothSubscription);
              } else if (c.uuid.toString() ==
                  "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
                if (c.properties.read) {
                  List<int> value = await c.read();
                  print('pump status: $value');
                }
              }
            }
          }
        }
      } else if (state == BluetoothConnectionState.disconnected) {
        print('Device is disconnected');
      }
    });
  }

  @override
  void dispose() {
    _bluetoothSubscription?.cancel(); // Cancel the subscription
    // Optionally disconnect the device if needed
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> waterKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> sunKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> humidityKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> airTempKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> earthTempKey = GlobalKey<TooltipState>();

    List tooltips = [waterKey, sunKey, humidityKey, airTempKey, earthTempKey];

    int waterMax = widget.plantCard.waterNeedsMax;
    int waterPercentage = ((0 / waterMax) * 100).round();
    int sunMax = widget.plantCard.sunLuxMax;
    int humidityMax = widget.plantCard.humidityMax;
    int airTempMax = widget.plantCard.airTempMax;

    if (plantSensor == null) {
      return const CircularProgressIndicator(); // Or some loading widget
    }

    int waterSensor = plantSensor!.water;
    int sunSensor = plantSensor!.sunLux;
    int airTempSensor = plantSensor!.airTemp;
    int earthTempSensor = plantSensor!.earthTemp;
    int humiditySensor = plantSensor!.humidity;

    return GestureDetector(
      onTap: () async {
        if (showingToolTips) return;
        showingToolTips = true;

        for (var tool in tooltips) {
          tool.currentState?.ensureTooltipVisible();
          await Future.delayed(Duration(milliseconds: 200), () {
            Tooltip.dismissAllToolTips();
          });
        }

        showingToolTips = false;
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.plantCard.name), centerTitle: true),
        body: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(width: 300, child: Image.asset('./images/plant_test.png')),
            Center(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 255, 245, 235),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 3),
                ),
                width: 350,
                height: 350,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ...buildSensorProgress(
                      'Vand',
                      '$waterPercentage%',
                      Icons.water_drop,
                      waterKey,
                      waterSensor,
                      waterMax,
                      [255, 120, 180, 220],
                    ),
                    ...buildSensorProgress(
                      'Sollys',
                      'Lux',
                      Icons.wb_sunny,
                      sunKey,
                      sunSensor,
                      sunMax,
                      [255, 255, 213, 79],
                    ),
                    ...buildSensorProgress(
                      'Fugt',
                      '%',
                      Icons.foggy,
                      humidityKey,
                      humiditySensor,
                      humidityMax,
                      [255, 139, 193, 183],
                    ),
                    ...buildSensorProgress(
                      'Luft temperatur',
                      '℃',
                      Icons.thermostat,
                      airTempKey,
                      airTempSensor,
                      airTempMax,
                      [255, 255, 183, 77],
                    ),
                    ...buildSensorProgress(
                      'Jord temperatur',
                      '℃',
                      Icons.thermostat,
                      earthTempKey,
                      earthTempSensor,
                      30,
                      [255, 188, 170, 164],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TooltipIcon extends StatelessWidget {
  final GlobalKey<TooltipState> tooltipkey;
  final String iconName;
  final IconData iconSymbol;
  final Color color;
  const TooltipIcon({
    super.key,
    required this.tooltipkey,
    required this.iconName,
    required this.iconSymbol,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      key: tooltipkey,
      message: iconName,
      preferBelow: false,
      child: GestureDetector(
        onTap: () {
          tooltipkey.currentState?.ensureTooltipVisible();
          Future.delayed(Duration(milliseconds: 400), () {
            Tooltip.dismissAllToolTips();
          });
        }, // Absorbs tap, does nothing
        child: Icon(
          iconSymbol,
          color: color, // Match Water bar
        ),
      ),
    );
  }
}

double getProgressBarPercentage(int sensorValue, int maxValue) {
  return (sensorValue / maxValue);
}

List<Widget> buildSensorProgress(
  String label,
  String unitName,
  IconData icon,
  GlobalKey<TooltipState> tooltipKey,
  int sensorValue,
  int maxValue,
  List<int> colorCode,
) {
  return [
    Align(
      alignment: Alignment.centerRight,
      child: Text('$sensorValue/$maxValue ($unitName)'),
    ),
    Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TooltipIcon(
          tooltipkey: tooltipKey,
          iconName: label,
          iconSymbol: icon,
          color: Color.fromARGB(
            colorCode[0],
            colorCode[1],
            colorCode[2],
            colorCode[3],
          ),
        ),
        SizedBox(width: 10),
        SizedBox(
          width: 260,
          child: LinearProgressIndicator(
            backgroundColor: Color.fromARGB(
              85,
              colorCode[1],
              colorCode[2],
              colorCode[3],
            ), // Sunlight bg
            borderRadius: BorderRadius.circular(25),
            color: Color.fromARGB(
              colorCode[0],
              colorCode[1],
              colorCode[2],
              colorCode[3],
            ), // Sunlight bar
            minHeight: 20,
            value: getProgressBarPercentage(sensorValue, maxValue),
          ),
        ),
      ],
    ),
  ];
}
