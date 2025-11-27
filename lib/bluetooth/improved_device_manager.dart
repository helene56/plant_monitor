import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:sqflite/sqflite.dart';

import '/data/plant_sensor_data.dart';
import '/data/database_helper.dart';
import 'package:plant_monitor/main.dart';
import 'bt_uuid.dart';

// Represents a logical sensor (your own abstraction, not FlutterBluePlus' BluetoothDevice).
class Device {
  final String deviceId;   // usually BluetoothDevice.remoteId.toString()
  final String deviceName;

  const Device({required this.deviceId, required this.deviceName});
}

class SensorReadings {
  final double airTemp;
  final List<int> pumpValue;

  const SensorReadings({required this.airTemp, required this.pumpValue});
}

class DeviceManagerState {
  /// Devices that have been saved/paired (from DB).
  final List<Device> persistentDevices;

  /// Devices that are currently connected.
  final List<Device> connectedDevices;

  /// Devices that have been scanned but not necessarily saved.
  final List<Device> scannedDevices;

  /// Should be true when "tilføj" has been pressed.
  final bool timeToAddSensor;

  final int? selectedIndex;
  final int? currentPlantId;

  /// Convenience: union of persistent and scanned, without duplicates.
  List<Device> get allDevices => [
        ...persistentDevices,
        ...scannedDevices.where(
          (s) => !persistentDevices.any((p) => p.deviceId == s.deviceId),
        ),
      ];

  const DeviceManagerState({
    required this.persistentDevices,
    this.connectedDevices = const [],
    this.scannedDevices = const [],
    this.timeToAddSensor = false,
    this.selectedIndex,
    this.currentPlantId,
  });

  DeviceManagerState copyWith({
    List<Device>? persistentDevices,
    List<Device>? connectedDevices,
    List<Device>? scannedDevices,
    bool? timeToAddSensor,
    int? selectedIndex,
    int? currentPlantId,
  }) {
    return DeviceManagerState(
      persistentDevices: persistentDevices ?? this.persistentDevices,
      connectedDevices: connectedDevices ?? this.connectedDevices,
      scannedDevices: scannedDevices ?? this.scannedDevices,
      timeToAddSensor: timeToAddSensor ?? this.timeToAddSensor,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      currentPlantId: currentPlantId ?? this.currentPlantId,
    );
  }
}

class DeviceManager extends StateNotifier<DeviceManagerState> {
  final Database db;

  /// Keep track of actual BluetoothDevice instances for connected/saved IDs.
  final Map<String, BluetoothDevice> _bleDevices = {};

  /// Connection-state subscriptions per deviceId.
  final Map<String, StreamSubscription<BluetoothConnectionState>>
      _connectionSubscriptions = {};

  DeviceManager(this.db)
      : super(const DeviceManagerState(persistentDevices: [])) {
    _init();
  }

  Future<void> _init() async {
    await _initializeBluetooth();
    await _loadPersistentDevicesFromDb();
    await _autoConnectPersistentDevices();
    await scanForDevices();
  }

  // ======================
  // Initialization / setup
  // ======================

  Future<void> _initializeBluetooth() async {
    FlutterBluePlus.setLogLevel(LogLevel.verbose, color: true);

    if (await FlutterBluePlus.isSupported == false) {
      if (kDebugMode) {
        debugPrint("Bluetooth not supported by this device");
      }
      return;
    }

    // Observe adapter state (you might extend this later for UI feedback).
    final subscription =
        FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
      if (state == BluetoothAdapterState.on) {
        // ready
      } else {
        // bt off / unauthorized, etc.
      }
    });

    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    // We only needed the initial response in this simple example.
    subscription.cancel();
  }

  Future<void> _loadPersistentDevicesFromDb() async {
    final sensors = await getAllSensors(db);
    final devices = sensors
        .map(
          (s) => Device(
            deviceId: s.remoteId,
            deviceName: s.sensorName,
          ),
        )
        .toList();

    state = state.copyWith(persistentDevices: devices);
  }

  Future<void> _autoConnectPersistentDevices() async {
    if (!kIsWeb && Platform.isAndroid) {
      await FlutterBluePlus.turnOn();
    }

    for (final device in state.persistentDevices) {
      await _connectAndListenToDevice(device.deviceId);
    }
  }

  // ======================
  // Core BLE logic
  // ======================

  /// Central place to connect to a device and start listening to its state.
  Future<void> _connectAndListenToDevice(String deviceId) async {
    final bleDevice = BluetoothDevice.fromId(deviceId);
    _bleDevices[deviceId] = bleDevice;

    // Ensure we don't stack multiple subscriptions.
    await _connectionSubscriptions[deviceId]?.cancel();

    final subscription = bleDevice.connectionState.listen(
      (BluetoothConnectionState connectionState) {
        _onConnectionStateChanged(deviceId, connectionState);
      },
    );

    // Auto-cancel when disconnected (as per FlutterBluePlus helper).
    bleDevice.cancelWhenDisconnected(subscription, delayed: true, next: true);
    _connectionSubscriptions[deviceId] = subscription;

    // If not already connected, try to connect.
    final currentState = await bleDevice.connectionState.first;
    if (currentState != BluetoothConnectionState.connected) {
      try {
        await bleDevice.connect(autoConnect: true, mtu: null);
      } catch (e) {
        if (kDebugMode) {
          debugPrint("Could not connect to $deviceId: $e");
        }
      }
    }
  }

  void _onConnectionStateChanged(
    String deviceId,
    BluetoothConnectionState connectionState,
  ) {
    final device = _findDeviceById(deviceId);
    if (device == null) {
      return;
    }

    if (connectionState == BluetoothConnectionState.connected) {
      // Add to connectedDevices if not already there.
      if (!state.connectedDevices.any((d) => d.deviceId == deviceId)) {
        state = state.copyWith(
          connectedDevices: [...state.connectedDevices, device],
        );
      }
    } else if (connectionState == BluetoothConnectionState.disconnected) {
      // Remove from connectedDevices.
      final updated = state.connectedDevices
          .where((d) => d.deviceId != deviceId)
          .toList();
      state = state.copyWith(connectedDevices: updated);
    }
  }

  Device? _findDeviceById(String deviceId) {
    try {
      return state.persistentDevices
              .firstWhere((d) => d.deviceId == deviceId) ??
          state.scannedDevices.firstWhere((d) => d.deviceId == deviceId);
    } catch (_) {
      // if not found in either list
      for (final d in [...state.persistentDevices, ...state.scannedDevices]) {
        if (d.deviceId == deviceId) return d;
      }
      return null;
    }
  }

  // ======================
  // Public helpers / state
  // ======================

  void addPersistentDevice(Device device) {
    if (!hasDeviceWithId(device.deviceId)) {
      state = state.copyWith(
        persistentDevices: [...state.persistentDevices, device],
      );
    }
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

  List<Device> get connectedDevices => state.connectedDevices;

  /// If you want a classic Stream<List<Device>> for StreamBuilder:
  Stream<List<Device>> get connectedDevicesStream =>
      stream.map((s) => s.connectedDevices);

  // ======================
  // Scanning
  // ======================

  Future<void> scanForDevices() async {
    final subscription = FlutterBluePlus.onScanResults.listen(
      (results) {
        if (results.isNotEmpty) {
          final r = results.last; // most recent result

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
      },
      onError: (e) => print(e),
    );

    FlutterBluePlus.cancelWhenScanComplete(subscription);

    await FlutterBluePlus.adapterState
        .where((val) => val == BluetoothAdapterState.on)
        .first;

    await FlutterBluePlus.startScan(
      withServices: [Guid(BtUuid.serviceId)],
      timeout: const Duration(minutes: 10),
    );

    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  // ======================
  // Reading sensor values
  // ======================

  Future<SensorReadings> getServices(BluetoothDevice device) async {
    final services = await device.discoverServices();
    double airTemperature = 0;
    List<int> pumpValue = [0];

    for (final service in services) {
      if (service.serviceUuid.toString() == BtUuid.serviceId) {
        for (final c in service.characteristics) {
          if (c.uuid.toString() ==
              "0f956142-6b9c-4a41-a6df-977ac4b99d78") {
            if (c.properties.read) {
              final temperatureValue = await c.read();
              airTemperature = temperatureValue[0].toDouble();
              if (kDebugMode) {
                debugPrint("Temperature: $temperatureValue");
              }
            }
          }
          if (c.uuid.toString() ==
              "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
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

  // ======================
  // Adding a new sensor (user action)
  // ======================

  Future<void> addSensor(int newPlantId) async {
    if (state.selectedIndex == null || !state.timeToAddSensor) {
      return;
    }

    final selectedDevice = state.allDevices[state.selectedIndex!];

    // Ensure we are connected to this device.
    await _connectAndListenToDevice(selectedDevice.deviceId);
    final bleDevice = _bleDevices[selectedDevice.deviceId]!;

    final initialSensorValues = await getServices(bleDevice);

    final sensor = PlantSensorData(
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

    // Add to persistent list and therefore to "saved sensors".
    addPersistentDevice(
      Device(
        deviceId: selectedDevice.deviceId,
        deviceName: selectedDevice.deviceName,
      ),
    );

    _resetTimeToAdd();
    _resetScannedDevices();
  }

  @override
  void dispose() {
    for (final sub in _connectionSubscriptions.values) {
      sub.cancel();
    }
    super.dispose();
  }
}

/// Riverpod provider for the manager.
final deviceManagerProvider =
    StateNotifierProvider<DeviceManager, DeviceManagerState>(
  (ref) => DeviceManager(ref.read(appDatabase)),
);
