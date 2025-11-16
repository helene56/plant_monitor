import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '/data/plant_sensor_data.dart';
import '/data/database_helper.dart';
import 'package:plant_monitor/main.dart';
import 'bt_uuid.dart';

import 'dart:io';
import 'package:flutter/foundation.dart';

// TODO: consider renaming because it might be confused with bluetooth device or simply convert to bluetoothdevice?
class Device {
  final String deviceId;
  final String deviceName;

  const Device({required this.deviceId, required this.deviceName});
}

// todo add ? to the values as it might not get the services
class SensorReadings {
  final double airTemp;
  final List<int> pumpValue;

  const SensorReadings({required this.airTemp, required this.pumpValue});
}

class DeviceManagerState {
  final List<Device> persistentDevices;
  final bool timeToAddSensor; // should be true when 'tilføj' has been pressed
  final int? selectedIndex;
  final int? currentPlantId;
  final List<Device> scannedDevices;
  List<Device> get allDevices => [
    ...persistentDevices,
    ...scannedDevices.where(
      (s) => !persistentDevices.any((p) => p.deviceId == s.deviceId),
    ),
  ];

  const DeviceManagerState({
    required this.persistentDevices,
    this.timeToAddSensor = false,
    this.selectedIndex,
    this.currentPlantId,
    this.scannedDevices = const [], // scannedDevices not already connected once
  });

  // Helper method for creating updated states
  DeviceManagerState copyWith({
    List<Device>? devices,
    bool? timeToAddSensor,
    int? selectedIndex,
    int? currentPlantId,
    List<Device>? scannedDevices,
  }) {
    return DeviceManagerState(
      persistentDevices: devices ?? persistentDevices,
      timeToAddSensor: timeToAddSensor ?? this.timeToAddSensor,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      currentPlantId: currentPlantId ?? this.currentPlantId,
      scannedDevices: scannedDevices ?? this.scannedDevices,
    );
  }
}

class DeviceManager extends StateNotifier<DeviceManagerState> {
  final Database db;

  DeviceManager(this.db)
    : super(const DeviceManagerState(persistentDevices: [])) {
    // One-time initialization
    _initializeBluetooth();
    // autoconnect if devices is not empty
    _autoConnectDevice();
    // start scanning for devices
    scanForDevices();
  }

  Future<void> _initializeBluetooth() async {
    // set log level
    // if your terminal doesn't support color you'll see annoying logs like `\x1B[1;35m`
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);
    // first, check if bluetooth is supported by your hardware
    // Note: The platform is initialized on the first call to any FlutterBluePlus method.
    if (await FlutterBluePlus.isSupported == false) {
      if (kDebugMode) {
        debugPrint("Bluetooth not supported by this device");
      }
      return;
    }

    // handle bluetooth on & off
    // note: for iOS the initial state is typically BluetoothAdapterState.unknown
    // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
    var subscription = FlutterBluePlus.adapterState.listen((
      BluetoothAdapterState state,
    ) {
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

  Future<void> _autoConnectDevice() async {
    // if getSensor is not empty
    // autoconnect device and add to devices
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    List<PlantSensorData> sensors = await getAllSensors(db);
    // check if any sensors where found
    if (sensors.isNotEmpty) {
      for (var sensor in sensors) {
        final device = BluetoothDevice.fromId(sensor.remoteId);

        // Skip if already connected
        final currentState = await device.connectionState.first;
        if (currentState == BluetoothConnectionState.connected) {
          print("Already connected to ${sensor.remoteId}");
          continue;
        }

        try {
          // First ensure we scanned recently
          await FlutterBluePlus.startScan(timeout: Duration(seconds: 3));

          await device.connect(autoConnect: true, mtu: null);

          try {
            // waits until the device enters the "connected" state
            await device.connectionState
                .where((s) => s == BluetoothConnectionState.connected)
                .first
                .timeout(const Duration(seconds: 5));

            // Add to UI state
            if (!hasDeviceWithId(sensor.remoteId)) {
              state = state.copyWith(
                devices: [
                  ...state.persistentDevices,
                  Device(
                    deviceId: sensor.remoteId,
                    deviceName: sensor.sensorName,
                  ),
                ],
              );
            }

            print("Connected! new new device");
          } catch (e) {
            print("Connection timed out — device never connected.");
          }
        } catch (e) {
          print("Could not connect to ${sensor.remoteId}: $e");
        }
      }
    }
  }

  // add device to DeviceManager
  void addDevice(Device device) {
    state = state.copyWith(devices: [...state.persistentDevices, device]);
  }

  void selectDevice(int? index) {
    state = state.copyWith(selectedIndex: index);
  }

  void updatePlantId(int? id) {
    state = state.copyWith(currentPlantId: id);
  }

  void _resetTimeToAdd() {
    state = state.copyWith(timeToAddSensor: false);
  }

  void _resetScannedDevices() {
    state = state.copyWith(scannedDevices: const []);
  }

  bool get isDeviceSelected => state.selectedIndex != null;

  bool hasDeviceWithId(String id) {
    return state.persistentDevices.any((device) => device.deviceId == id);
  }

  void setTimeToAddSensor(bool value) {
    state = state.copyWith(timeToAddSensor: value);
  }

  // 1. scan for devices when add_plant is opened
  Future<void> scanForDevices() async {
    var subscription = FlutterBluePlus.onScanResults.listen((results) {
      if (results.isNotEmpty) {
        ScanResult r = results.last; // the most recently found device
        // add results found to scanned devices
        if (!hasDeviceWithId(r.device.remoteId.toString())) {
          state = state.copyWith(
            scannedDevices: [
              ...state.scannedDevices,
              Device(
                deviceId: r.device.remoteId.toString(),
                deviceName: r.advertisementData.advName,
              ),
            ],
          );
        }

        if (kDebugMode) {
          debugPrint(
            '${r.device.remoteId}: "${r.advertisementData.advName}" found!',
          );
        }
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
      withServices: [
        Guid(BtUuid.serviceId),
      ], // match any of the specified services
      // withNames: ["MY_PWS1"], // *or* any of the specified names
      timeout: Duration(
        minutes: 10,
      ), // maybe set a really large timout, but stop with stopScan
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  Future<SensorReadings> getServices(BluetoothDevice device) async {
    // Note: You must call discoverServices after every re-connection!
    List<BluetoothService> services = await device.discoverServices();
    double airTemperature = 0;
    List<int> pumpValue = [0];
    for (var service in services) {
      if (service.serviceUuid.toString() == BtUuid.serviceId) {
        for (var c in service.characteristics) {
          if (c.uuid.toString() == "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
            if (c.properties.read) {
              List<int> temperatureValue = await c.read();
              airTemperature = temperatureValue[0].toDouble();
              if (kDebugMode) {
                debugPrint("Temperature: $temperatureValue");
              }
            }
          }
          if (c.uuid.toString() == "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
            if (c.properties.read) {
              pumpValue = await c.read();
              if (kDebugMode) {
                debugPrint("Pump: $pumpValue");
              }
            }
          }
        }
      }
    }

    return SensorReadings(airTemp: airTemperature, pumpValue: pumpValue);
  }

  // 2. connect sensor, then add sensor to db and reset timeToAddSensor and reset scanned devices
  Future<void> addSensor(int newPlantId) async {
    if (state.selectedIndex != null && state.timeToAddSensor) {
      var selectedDevice = state.allDevices[state.selectedIndex!];
      // initialize bluetooth device
      var device = BluetoothDevice.fromId(selectedDevice.deviceId);
      // connect to device (if not connected)
      if (!device.isConnected) {
        await connectToDevice(device);
      }

      // read initial values from sensor
      SensorReadings initialSensorValues = await getServices(device);

      var sensor = PlantSensorData(
        plantId: newPlantId,
        remoteId: selectedDevice.deviceId,
        sensorName: selectedDevice.deviceName,
        water: 0,
        sunLux: 0,
        airTemp: initialSensorValues.airTemp,
        earthTemp: 0,
        humidity: 0,
      );

      await insertRecord(db, 'plant_sensor', sensor.toMap());

      state = state.copyWith(
        devices: [
          ...state.persistentDevices,
          Device(
            deviceId: selectedDevice.deviceId,
            deviceName: selectedDevice.deviceName,
          ),
        ],
      );

      _resetTimeToAdd();
      _resetScannedDevices();
    }
  }
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

final deviceManagerProvider =
    StateNotifierProvider<DeviceManager, DeviceManagerState>(
      (ref) => DeviceManager(ref.read(appDatabase)), // Inject initialized DB
    );
