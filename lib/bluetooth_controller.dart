import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:plant_monitor/main.dart';
import 'data/plant_sensor_data.dart';
import 'data/database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyBluetooth extends ConsumerStatefulWidget {
  final bool onAddDevice;
  final bool exitAddPlant;
  final int currentPlantId;
  // final Function(DeviceIdentifier) onDataSubmit;
  const MyBluetooth({
    super.key,
    required this.onAddDevice,
    required this.exitAddPlant,
    required this.currentPlantId,
    // required this.onDataSubmit
  });

  @override
  ConsumerState<MyBluetooth> createState() => _MyBluetoothState();
}

class _MyBluetoothState extends ConsumerState<MyBluetooth> {
  late final Database db;
  @override
  void initState() {
    super.initState();
    initializeBluetooth(); // TODO: should really only happen once, dont call more than once
    // move this function to initializeBluetooth?
    db = ref.read(appDatabase);
    autoConnectDevice();
    
    scanResults(); // Automatically starts scanning when MyBluetooth is started
  }
  
  bool isInList(BluetoothDevice device) {
    return devices.any((entry) => entry['device'].remoteId == device.remoteId);
  }

  Future<void> addDevice() async {
    // TODO: deal with the situation where no device is connected
    if (_value != null) {
      var selectedDevice = devices[_value!]['device'];

      if (selectedDevice.isConnected) {
        getServices(selectedDevice);
      } else {
        // connect to device
        connectToDevice(selectedDevice).then((_) {
          // get services and insert selected device in database
          getServices(selectedDevice);
        });
      }

      print("connected to $selectedDevice.advertisementData.advName");
    }
  }

  Future<void> addSensor(
    BluetoothDevice selectedDevice,
    int airTemperature,
  ) async {
    // TODO: give sensor its own id, should just make sqlite update it automatically -> see plant_containers
    var sensor = PlantSensorData(
      id: widget.currentPlantId,
      sensorId: selectedDevice.remoteId.toString(),
      sensorName: selectedDevice.advName,
      water: 0,
      sunLux: 0,
      airTemp: airTemperature,
      earthTemp: 0,
      humidity: 0,
    );

    await insertRecord(db, 'plant_sensor', sensor.toMap());
    // var sensors = await getSensors(widget.database);
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    // listen for disconnection
    var subscription = device.connectionState.listen((
      BluetoothConnectionState state,
    ) async {
      if (state == BluetoothConnectionState.disconnected) {
        // 1. typically, start a periodic timer that tries to
        //    reconnect, or just call connect() again right now
        // 2. you must always re-discover services after disconnection!
        print(
          "${device.disconnectReason?.code} ${device.disconnectReason?.description}",
        );
      }
    });

    // cleanup: cancel subscription when disconnected
    //   - [delayed] This option is only meant for `connectionState` subscriptions.
    //     When `true`, we cancel after a small delay. This ensures the `connectionState`
    //     listener receives the `disconnected` event.
    //   - [next] if true, the the stream will be canceled only on the *next* disconnection,
    //     not the current disconnection. This is useful if you setup your subscriptions
    //     before you connect.
    device.cancelWhenDisconnected(subscription, delayed: true, next: true);

    // Connect to the device
    await device.connect();

    // cancel to prevent duplicate listeners
    subscription.cancel();
  }

  Future<void> initializeBluetooth() async {
    // set log level
    // if your terminal doesn't support color you'll see annoying logs like `\x1B[1;35m`
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: false);
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      print("Bluetooth not supported by this device");
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    var subscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState state,
    ) {
      print(state);
      if (state == BluetoothAdapterState.on) {
        // usually start scanning, connecting, etc
      } else {
        // show an error to the user, etc
      }
    });

    // turn on bluetooth ourself if we can
    // for iOS, the user controls bluetooth enable/disable
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // cancel to prevent duplicate listeners
    subscription.cancel();
  }

  Future<void> scanResults() async {
    print("starting scanning..");
    // listen to scan results
    // Note: `onScanResults` clears the results between scans. You should use
    //  `scanResults` if you want the current scan results *or* the results from the previous scan.
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        // add results found
        if (!isInList(r.device)) {
          setState(() {
            devices.add({
              'device': r.device,
              'deviceName': r.advertisementData.advName,
            });
          });
        }

        print('${r.device.remoteId}: "${r.advertisementData.advName}" found!');
      }
    }, onError: (e) => print(e));

    // cleanup: cancel subscription when scanning stops
    FlutterBluePlus.cancelWhenScanComplete(subscription);

    // Wait for Bluetooth enabled & permission granted
    // In your real app you should use `FlutterBluePlus.adapterState.listen` to handle all states
    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    // Start scanning w/ timeout
    // Optional: use `stopScan()` as an alternative to timeout
    // TODO: specify my own identifiers, easier to look for identifier instead of names
    await FlutterBluePlus.startScan(
      // withServices: [Guid("180D")], // match any of the specified services
      withNames: ["MY_PWS1"], // *or* any of the specified names
      timeout: Duration(
        minutes: 10,
      ), // maybe set a really large timout, but stop with stopScan
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  // Helper function, might remove later on
  Future<void> getServices(BluetoothDevice device) async {
    // Note: You must call discoverServices after every re-connection!
    List<BluetoothService> services = await device.discoverServices();
    int airTemperature = 0;

    for (var service in services) {
      if (service.serviceUuid.toString() ==
          "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
            if (c.properties.read) {
              List<int> temperatureValue = await c.read();
              airTemperature = temperatureValue[0];
              print("Temperature: $temperatureValue");
            }
          }
          if (c.uuid.toString() == "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
            if (c.properties.read) {
              List<int> pumpValue = await c.read();
              print("Pump: $pumpValue");
            }
          }
        }
      }
    }

    addSensor(device, airTemperature);

  }

  Future<void> autoConnectDevice() async {
    // if getSensor is not empty
    // autoconnect device and add to devices
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }
    
    List<PlantSensorData> sensors = await getAllSensors(db);
    for (var sensor in sensors) {
      var device = BluetoothDevice.fromId(sensor.sensorId);
      await device.connect(autoConnect: true, mtu: null).then((_) {});

      await device.connectionState.firstWhere(
        (state) => state == BluetoothConnectionState.connected,
      );

      if (!isInList(device)) {
        setState(() {
          devices.add({'device': device, 'deviceName': sensor.sensorName});
        });
      }
    }
  }

  Future<void> subscibeToDevice(BluetoothDevice device) async {
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      if (service.serviceUuid.toString() ==
          "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
            // Enable notifications
            await c.setNotifyValue(true);
            // Listen for value changes
            final subscription = c.onValueReceived.listen((value) {
              print('Sensor data: $value');
            });
            // Automatically cancel subscription when device disconnects
            device.cancelWhenDisconnected(subscription);
          }
        }
      }
    }
  }

  int? _value = 0;
  List<Map<String, dynamic>> devices = [];

  @override
  Widget build(BuildContext context) {
    
    if (widget.onAddDevice) {
      addDevice();
    }
    if (widget.exitAddPlant) {
      FlutterBluePlus.stopScan();
    }
    if (devices.isNotEmpty) {
      return Wrap(
        spacing: 5.0,
        children:
            List<Widget>.generate(devices.length, (int index) {
              return ChoiceChip(
                label: Text(devices[index]['deviceName']),
                selected: _value == index,
                onSelected: (bool selected) {
                  setState(() {
                    _value = selected ? index : null;
                  });
                },
              );
            }).toList(),
      );
    } else {
      return Container(); // should not show anything in case no devices are found
    }
  }
}
