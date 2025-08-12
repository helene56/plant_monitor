import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:plant_monitor/data/database_helper.dart';
import 'package:plant_monitor/data/plant.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:plant_monitor/main.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:plant_monitor/data/sensor_cmd_id.dart';

class MyPlantStat extends ConsumerStatefulWidget {
  final Plant plantCard;
  const MyPlantStat({super.key, required this.plantCard});

  @override
  ConsumerState<MyPlantStat> createState() => _MyPlantStatState();
}

class _MyPlantStatState extends ConsumerState<MyPlantStat>
    with TickerProviderStateMixin {
  bool showingToolTips = false;
  PlantSensorData? plantSensor;
  StreamSubscription? _bluetoothSubscription;
  int sensorStatus = 0; // assumes sensor is off
  late final BluetoothDevice _device;
  String connectionStatus = "Ikke\ntilsluttet";
  late AnimationController controller;
  bool showCalibrationProgress = false;
  @override
  void initState() {
    super.initState();
    initializeSensor();
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 10),
    )..addListener(() {
      setState(() {});
    });
  }

  void initializeSensor() async {
    PlantSensorData data = await getSensor(
      ref.read(appDatabase),
      widget.plantCard.id,
    );
    setState(() {
      plantSensor = data;
    });
    _device = BluetoothDevice.fromId(plantSensor!.sensorId);
    toggleSensorTemperature(_device); // activate sensor reading
    subscibeToDevice(_device); // subscribe to get sensor readings
  }

  Future<void> toggleSensorTemperature(BluetoothDevice device) async {
    if (device.isDisconnected) {
      // Connect to the device
      await autoConnectDevice();
    }

    device.connectionState.listen((state) async {
      if (state == BluetoothConnectionState.connected) {
        try {
          List<BluetoothService> services = await device.discoverServices();
          for (var service in services) {
            // do something with service
            if (service.serviceUuid.toString() ==
                "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
              // Iterate through characteristics
              for (var characteristic in service.characteristics) {
                if (characteristic.characteristicUuid.toString() ==
                    "0f956144-6b9c-4a41-a6df-977ac4b99d78") {
                  // toggle sensor on/off
                  sensorStatus ^= 1;
                  int status = sensorStatus << 7;
                  int onOffTempHumidity =
                      status | SensorCmdId.temperatureHumidity;
                  // TODO: try catch before await here as well
                  // Write to the characteristic
                  await characteristic.write([onOffTempHumidity]);

                  print("Toggled sensor");
                }
              }
            }
          }
        } catch (e) {
          print('Error reading characteristic: $e');
          if (mounted) {
            setState(() {
              connectionStatus = "Ikke\nTilsluttet";
            });
          }
        }
      }
    });
  }

  Future<void> autoConnectDevice() async {
    // if getSensor is not empty
    // autoconnect device and add to devices
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    List<PlantSensorData> sensors = await getAllSensors(ref.read(appDatabase));
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
        if (mounted) {
          setState(() {
            connectionStatus = "Tilsluttet";
          });
        }

        try {
          List<BluetoothService> services = await device.discoverServices();
          for (var service in services) {
            if (service.serviceUuid.toString() ==
                "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
              for (var c in service.characteristics) {
                if (c.uuid.toString() ==
                    "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
                  try {
                    // Enable notifications
                    await c.setNotifyValue(true);
                    // Listen for value changes
                    final bluetoothSubscription = c.onValueReceived.listen((
                      value,
                    ) async {
                      if (!mounted) {
                        return; // Check if the widget is still mounted
                      }
                      if (plantSensor == null) {
                        // Still not ready, so skip this update
                        return;
                      }
                      // update plantsensor -- should update database
                      if (mounted) {
                        final byteData = ByteData.sublistView(
                          Uint8List.fromList(value),
                        );
                        int rawTemp = byteData.getInt16(0, Endian.little);
                        print('Temperature: ${rawTemp / 10.0} °C');

                        double readAirTemp = rawTemp / 10;
                        rawTemp = byteData.getInt16(2, Endian.little);
                        double readAirHumidity = rawTemp / 10;
                        setState(() {
                          plantSensor = plantSensor!.copyWith(
                            airTemp: readAirTemp,
                          );
                          plantSensor = plantSensor!.copyWith(
                            humidity: readAirHumidity,
                          );
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
                  } catch (e) {
                    print('Error reading characteristic: $e');
                    if (mounted) {
                      setState(() {
                        connectionStatus = "Ikke\nTilsluttet";
                      });
                    }
                  }
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
        } catch (e) {
          print('Error reading characteristic: $e');
          if (mounted) {
            setState(() {
              connectionStatus = "Ikke\nTilsluttet";
            });
          }
        }
      } else if (state == BluetoothConnectionState.disconnected) {
        print('ddevice is disconnected');
        print('this means it went out of range??');
        if (mounted) {
          setState(() {
            connectionStatus = "Ikke\ntilsluttet";
            sensorStatus = 0;
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _bluetoothSubscription?.cancel(); // Cancel the subscription
    // Optionally disconnect the device if needed
    super.dispose();
  }

  String calibrationText = 'Kalibrér';
  String soilSensorText = 'Ikke\nkalibreret';
  Color calibrationButtonColor = Color.fromARGB(255, 85, 185, 125);

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

    double waterSensor = plantSensor!.water;
    double sunSensor = plantSensor!.sunLux;
    double airTempSensor = plantSensor!.airTemp;
    double earthTempSensor = plantSensor!.earthTemp;
    double humiditySensor = plantSensor!.humidity;

    return PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) async {
        print('Back button pressed or page is trying to pop');
        toggleSensorTemperature(
          _device,
        ); // dont recieve sensor readings anymore
      },
      child: GestureDetector(
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
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 300,
                    child: Image.asset('./images/plant_test.png'),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 40),
                      if (showCalibrationProgress)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                          child: SizedBox(
                            width: 95,
                            child: LinearProgressIndicator(
                              value: controller.value,
                            ),
                          ),
                        ),
                      SizedBox(height: 5),
                      FilledButton(
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all(
                            calibrationButtonColor,
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            calibrationText = 'Kalibrerer';
                            showCalibrationProgress = true;
                            controller.reset();
                            controller.forward();
                          });
                          Future.delayed(const Duration(seconds: 11), () {
                            if (mounted) {
                              setState(() {
                                showCalibrationProgress = false;
                                calibrationText = 'Kalibrér';
                                soilSensorText = 'Kalibreret';
                                calibrationButtonColor = Color.fromARGB(
                                  177,
                                  104,
                                  219,
                                  150,
                                );
                              });
                            }
                          });
                        },
                        child: Text(calibrationText),
                      ),
                      SizedBox(height: 25),
                      Text('Status:\n$connectionStatus'),
                      SizedBox(height: 25),
                      Text('Jord sensor:\n$soilSensorText'),
                    ],
                  ),
                ],
              ),
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

double getProgressBarPercentage(double sensorValue, int maxValue) {
  return (sensorValue / maxValue);
}

List<Widget> buildSensorProgress(
  String label,
  String unitName,
  IconData icon,
  GlobalKey<TooltipState> tooltipKey,
  double sensorValue,
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
