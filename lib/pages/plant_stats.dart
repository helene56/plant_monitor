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
import 'package:haptic_feedback/haptic_feedback.dart';

// TODO: somehow the page should remember the calibration state, as well as saving it to the db

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
      duration: const Duration(seconds: 21),
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
    _device = BluetoothDevice.fromId(plantSensor!.remoteId);
    toggleSensorTemperature(_device); // activate sensor reading
    subscribeToDevice(_device); // subscribe to get sensor readings
  }

  Future<bool> _writeToSensor(
    BluetoothDevice device,
    int cmdId,
    int cmdVal,
  ) async {
    final completer = Completer<bool>();

    if (device.isDisconnected) {
      // Connect to the device
      await autoConnectDevice();
    }
    late StreamSubscription sub;
    sub = device.connectionState.listen((state) async {
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
                  int shiftedCmdVal = cmdVal << 7;
                  int finalCmdByte = shiftedCmdVal | cmdId;
                  // TODO: try catch before await here as well
                  // Write to the characteristic
                  await characteristic.write([finalCmdByte]);
                  if (kDebugMode) {
                    debugPrint("Succusesfully wrote to sensor");
                  }
                  if (!completer.isCompleted) completer.complete(true);
                  await sub.cancel();
                  return;
                }
              }
            }
          }
          if (!completer.isCompleted) completer.complete(false);
          await sub.cancel();
        } catch (e) {
          if (kDebugMode) {
            debugPrint('Error reading characteristic: $e');
          }
          if (!completer.isCompleted) completer.complete(false);
          await sub.cancel();
          if (mounted) {
            setState(() {
              connectionStatus = "Ikke\nTilsluttet";
            });
          }
        }
      }
    });

    return completer.future;
  }

  Future<int> subscibeToCalibration(BluetoothDevice device) async {
    // Ensure device is connected
    if (device.isDisconnected) {
      await autoConnectDevice(); // make sure this awaits the connection
    }

    // Wait until device reports it is connected
    await device.connectionState.firstWhere(
      (state) => state == BluetoothConnectionState.connected,
    );

    // Now we are sure device is connected
    if (kDebugMode) {
      debugPrint('Device is connected');
    }

    try {
      final services = await device.discoverServices();

      final targetService = services.firstWhere(
        (s) =>
            s.serviceUuid.toString() == "0f956141-6b9c-4a41-a6df-977ac4b99d78",
        orElse: () => throw Exception("Service not found"),
      );

      final targetChar = targetService.characteristics.firstWhere(
        (c) => c.uuid.toString() == "0f956145-6b9c-4a41-a6df-977ac4b99d78",
        orElse: () => throw Exception("Characteristic not found"),
      );

      await targetChar.setNotifyValue(true);

      // Wait for the first calibration value
      final value = await targetChar.onValueReceived.firstWhere(
        (data) =>
            data.isNotEmpty &&
            (data[0] == CalibrationStates.dryFinish ||
                data[0] == CalibrationStates.idealFinish),
      );

      if (kDebugMode) {
        debugPrint("Received value: $value");
      }
      return value[0];
    } catch (e) {
      if (kDebugMode) {
        debugPrint("Error: $e");
      }
      return -1; // return error code
    }
  }

  Future<void> toggleSensorTemperature(BluetoothDevice device) async {
    // toggle sensor
    sensorStatus ^= 1;
    bool success = await _writeToSensor(
      device,
      SensorCmdId.temperatureHumidity,
      sensorStatus,
    );
    if (!success) {
      sensorStatus ^= 1; // revert
      if (mounted) {
        setState(() {
          connectionStatus = "Ikke\nTilsluttet";
        });
      }
    }
  }

  Future<void> startSoilCalibration(BluetoothDevice device) async {
    _writeToSensor(device, SensorCmdId.soilCal, 1);
  }

  Future<void> startPump(BluetoothDevice device) async {
    if (kDebugMode) {
      debugPrint("app: turning pump on.");
    }
    _writeToSensor(device, SensorCmdId.pump, 1);
  }

  Future<void> autoConnectDevice() async {
    // if getSensor is not empty
    // autoconnect device and add to devices
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    List<PlantSensorData> sensors = await getAllSensors(ref.read(appDatabase));
    for (var sensor in sensors) {
      var device = BluetoothDevice.fromId(sensor.remoteId);
      await device.connect(autoConnect: true, mtu: null).then((_) {});

      await device.connectionState.firstWhere(
        (state) => state == BluetoothConnectionState.connected,
      );
    }
  }

  Future<void> subscribeToDevice(BluetoothDevice device) async {
    if (device.isDisconnected) {
      await autoConnectDevice();
    }

    device.connectionState.listen((state) async {
      if (!mounted) return;

      if (state == BluetoothConnectionState.connected) {
        _updateConnectionStatus("Tilsluttet");
        if (kDebugMode) debugPrint('Device is connected');

        try {
          final services = await device.discoverServices();
          final matchingServices = services.where(
            (s) =>
                s.serviceUuid.toString() ==
                "0f956141-6b9c-4a41-a6df-977ac4b99d78",
          );

          if (matchingServices.isEmpty) return;

          final targetService = matchingServices.first;

          for (final c in targetService.characteristics) {
            final uuid = c.uuid.toString();

            if (uuid == "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
              _listenToSensor(c, device);
            } else if (uuid == "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
              if (c.properties.read) {
                final value = await c.read();
                if (kDebugMode) debugPrint('Pump status: $value');
              }
            }
          }
        } catch (e) {
          _handleConnectionError(e);
        }
      } else if (state == BluetoothConnectionState.disconnected) {
        _updateConnectionStatus("Ikke\ntilsluttet", sensorStatus: 0);
        if (kDebugMode) {
          debugPrint('Device is disconnected');
          debugPrint('Possibly out of range?');
        }
      }
    });
  }

  /// Helper to update UI safely
  void _updateConnectionStatus(String status, {int? sensorStatus}) {
    if (!mounted) return;
    setState(() {
      connectionStatus = status;
      if (sensorStatus != null) this.sensorStatus = sensorStatus;
    });
  }

  /// Helper to handle errors
  void _handleConnectionError(Object e) {
    if (kDebugMode) debugPrint('Error reading characteristic: $e');
    _updateConnectionStatus("Ikke\nTilsluttet");
  }

  /// Separate listener for sensor characteristic
  Future<void> _listenToSensor(
    BluetoothCharacteristic c,
    BluetoothDevice device,
  ) async {
    try {
      await c.setNotifyValue(true);
      final subscription = c.onValueReceived.listen((value) async {
        if (!mounted || plantSensor == null) return;

        final byteData = ByteData.sublistView(Uint8List.fromList(value));
        final readAirTemp = byteData.getInt16(0, Endian.little) / 10.0;
        final readAirHumidity = byteData.getInt16(2, Endian.little) / 10.0;

        if (kDebugMode) {
          debugPrint(
            'Temperature: $readAirTemp °C, Humidity: $readAirHumidity%',
          );
        }

        setState(() {
          plantSensor = plantSensor!.copyWith(
            airTemp: readAirTemp,
            humidity: readAirHumidity,
          );
        });

        await updateRecord(
          ref.read(appDatabase),
          'plant_sensor',
          plantSensor!.toMap(),
        );

        if (kDebugMode) debugPrint('Sensor data: $value');
      });

      device.cancelWhenDisconnected(subscription);
    } catch (e) {
      _handleConnectionError(e);
    }
  }

  String _tooltipMessage() {
    if (!_device.isConnected) return 'sensor ikke tilsluttet';
    if (calibrationWaitTime) return 'kalibrering stadig igang!';
    return '';
  }

  @override
  void dispose() {
    _bluetoothSubscription?.cancel(); // Cancel the subscription
    // Optionally disconnect the device if needed
    super.dispose();
  }

  String calibrationText = 'Kalibrér';
  String soilSensorText = 'Ikke\nkalibreret';
  Color calibrationButtonColor = const Color(0xFF55B97D);
  String popUpDialog =
      'Trin 1: Indsæt sensor i potteplanten.\nTrin 2: Vent på færdig kalibrering i tør tilstand\nTrin 3: Vand planten';
  bool calibrationWaitTime = false;
  bool calibrationFinish = false;
  String tooltipCali = '';

  @override
  Widget build(BuildContext context) {
    final GlobalKey<TooltipState> waterKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> sunKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> humidityKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> airTempKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> earthTempKey = GlobalKey<TooltipState>();
    final GlobalKey<TooltipState> tooltipkey = GlobalKey<TooltipState>();

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
        if (kDebugMode) {
          debugPrint('Back button pressed or page is trying to pop');
        }
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
                      Tooltip(
                        message: _tooltipMessage(),
                        key: tooltipkey,
                        triggerMode: TooltipTriggerMode.manual,
                        preferBelow: false,
                        child: FilledButton(
                          style: ButtonStyle(
                            backgroundColor: WidgetStateProperty.all(
                              calibrationButtonColor,
                            ),
                          ),
                          onPressed: () async {
                            tooltipkey.currentState?.ensureTooltipVisible();
                            if (_device.isConnected && !calibrationWaitTime) {
                              int result = await showCalibrationDialogFlow(
                                context,
                                controller,
                                _device,
                                startSoilCalibration,
                                startPump,
                                subscibeToCalibration,
                              );
                              if (result != -1) {
                                setState(() {
                                  soilSensorText = '1/2 Kalibreret';
                                  calibrationButtonColor = const Color(
                                    0xFFB0F5C8,
                                  );
                                  calibrationWaitTime = true;
                                });
                                int calibrationResult =
                                    await subscibeToCalibration(_device);
                                if (calibrationResult ==
                                    CalibrationStates.idealFinish) {
                                  await Haptics.vibrate(HapticsType.success);
                                  setState(() {
                                    soilSensorText = '2/2 Kalibreret';
                                    calibrationWaitTime = false;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Kalibrering færdig! 🎉'),
                                        duration: Duration(seconds: 4),
                                      ),
                                    );
                                  });
                                }
                              }
                            }
                          },
                          child: Text(calibrationText),
                        ),
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

Widget buildCalibration1(BuildContext context) {
  return AlertDialog(
    title: Text('Kalibrering'),
    content: Text(
      'Trin 1: Indsæt sensor i potteplanten og sørg for at have tilsuttet pumpen til vand.'
      '\nTrin 2: Vent på færdig kalibrering i tør tilstand.\nTrin 3: Planten vandes automatisk.',
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, 'Fortryd'),
        child: const Text('Fortryd'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context, 'START'),
        child: const Text('START'),
      ),
    ],
  );
}

Widget buildCalibration2(BuildContext context) {
  return AlertDialog(
    title: Text('Trin 1'),
    content: SizedBox(
      height: 245,
      child: Column(
        children: [
          const Text('Indsæt sensor og tilslut pumpe'),
          Image.asset(
            './images/plant-sensor-guide-dry12.png',
            width: 200,
            height: 200,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK'),
      ),
    ],
  );
}

Widget buildCalibration4(BuildContext context) {
  return AlertDialog(
    title: Text('Trin 3'),
    content: SizedBox(
      height: 245,
      child: Column(
        children: [
          const Text('Planten vandes'),
          Image.asset(
            './images/plant-sensor-guide-wet12.png',
            width: 200,
            height: 200,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, 'Færdig'),
        child: const Text('Færdig'),
      ),
    ],
  );
}

Widget buildCalibration5(BuildContext context) {
  return AlertDialog(
    title: Text('Færdig'),
    content: Text('Resten af kalibreringen klarer sensoren :)'),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, 'OK'),
        child: const Text('OK'),
      ),
    ],
  );
}

// TODO: this flow of dialog is very messy.. URGENT TO CLEAN UP!
Future<int> showCalibrationDialogFlow(
  BuildContext context,
  AnimationController controller,
  BluetoothDevice device,
  Future<void> Function(BluetoothDevice) startSoilCalibrationCallback,
  Future<void> Function(BluetoothDevice) startPumpCallback,
  Future<int> Function(BluetoothDevice) getCalibrationStatus,
) async {
  // Step 1
  final step1 = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => buildCalibration1(context),
  );
  if (step1 != 'START') return -1;

  // Step 2
  final step2 = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => buildCalibration2(context),
  );
  if (step2 != 'OK') return -1;
  await startSoilCalibrationCallback(device);
  // Step 3 (wait 11 seconds before showing OK)
  controller.reset();
  controller.forward();
  final step3 = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      bool showOk = false;
      return StatefulBuilder(
        builder: (context, setState) {
          if (!showOk) {
            Future.delayed(const Duration(seconds: 0), () async {
              // try to read sensor ok status
              int result = await getCalibrationStatus(device);
              if (result == CalibrationStates.dryFinish) {
                setState(() => showOk = true);
              }
            });
          }
          return AlertDialog(
            title: Text('Trin 2'),
            content: SizedBox(
              height: 245,
              child: Column(
                children: [
                  const Text('Vent'),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(7, 0, 7, 0),
                    child: SizedBox(
                      width: 95,
                      child: AnimatedBuilder(
                        animation: controller,
                        builder: (context, child) {
                          return LinearProgressIndicator(
                            value: controller.value,
                          );
                        },
                      ),
                    ),
                  ),
                  Image.asset('./images/plant-sensor-guide-dry.png'),
                ],
              ),
            ),
            actions: [
              if (showOk) ...[
                Text('Pumpen starter ved tryk:'),
                TextButton(
                  onPressed: () async {
                    await startPumpCallback(device);
                    Navigator.pop(context, 'OK');
                  },
                  child: const Text('OK'),
                ),
              ],
            ],
          );
        },
      );
    },
  );
  if (step3 != 'OK') return -1;

  // Step 4
  final step4 = await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => buildCalibration4(context),
  );
  if (step4 != 'Færdig') return -1;

  // Step 5
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => buildCalibration5(context),
  );

  return 0;
}
