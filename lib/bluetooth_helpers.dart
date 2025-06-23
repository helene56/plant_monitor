import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:plant_monitor/data/plant_sensor_data.dart';
import 'package:sqflite/sqflite.dart';
import 'data/database_helper.dart';

Future<void> autoConnectDevice(Database db) async {
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
  }
}

Future<int?> subscibeGetPumpStatus(BluetoothDevice device, Database db) async {
  if (device.isDisconnected) {
    // Connect to the device
    await autoConnectDevice(db);
  }

  // Wait until the device is connected
  await device.connectionState.firstWhere(
    (state) => state == BluetoothConnectionState.connected,
  );

  List<BluetoothService> services = await device.discoverServices();
  for (var service in services) {
    if (service.serviceUuid.toString() ==
        "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
      for (var c in service.characteristics) {
        if (c.uuid.toString() == "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
          if (c.properties.read) {
            List<int> value = await c.read();
            print('pump status: $value');
            return value[0];
          }
        }
      }
    }
  }
  return null; // If not found
}
