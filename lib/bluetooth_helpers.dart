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
    var device = BluetoothDevice.fromId(sensor.remoteId);
    await device.connect(autoConnect: true, mtu: null).then((_) {});

    await device.connectionState.firstWhere(
      (state) => state == BluetoothConnectionState.connected,
    );
  }
}

Future<double?> subscibeGetPumpWater(
  BluetoothDevice device,
  Database db,
) async {
  // Wait for the device to be connected, or try to connect if disconnected
  BluetoothConnectionState state = await device.connectionState.first;
  if (state == BluetoothConnectionState.disconnected) {
    try {
      await device
          .connect(autoConnect: false)
          .timeout(const Duration(seconds: 2));
    } catch (e) {
      return -1;
    }
  }

  // Wait until the device is connected (with timeout)
  try {
    await device.connectionState
        .firstWhere((s) => s == BluetoothConnectionState.connected)
        .timeout(const Duration(seconds: 2));
  } catch (e) {
    return -1;
  }

  List<BluetoothService> services = await device.discoverServices();
  for (var service in services) {
    if (service.serviceUuid.toString() ==
        "0f956141-6b9c-4a41-a6df-977ac4b99d78") {
      for (var c in service.characteristics) {
        if (c.uuid.toString() == "0f956143-6b9c-4a41-a6df-977ac4b99d78") {
          if (c.properties.read) {
            List<int> value = await c.read();
            if (kDebugMode) {
              debugPrint('pump status: $value');
            }
            // expecting 5 * 4 bytes
            if (value.length != 20) {
              if (kDebugMode) {
                debugPrint("Unexpected length: ${value.length}");
              }
              return -1;
            }

            // Convert List<int> to ByteData for parsing
            final byteData = ByteData.sublistView(Uint8List.fromList(value));

            List<int> uint32Values = [];
            for (int i = 0; i < 5; i++) {
              uint32Values.add(byteData.getUint32(i * 4, Endian.little));
            }

            if (kDebugMode) {
              debugPrint('pump status in 32bits: $uint32Values');
            }
            // for now just send off the latest value
            // but first lets calculate how much water is left
            // waterflow = 3L/min.
            // value is in ms
            // min to ms: 1 min = 60000 ms
            // 3L/60000 ms
            for (int i = 4; i > 0; --i) {
              if (uint32Values[i] != 0) {
                // convert to water output
                double waterOutput = uint32Values[i] * (3 / 60000); // L
                return waterOutput;
              }
            }

            // return value[0];
          }
        }
      }
    }
  }
  return -1; // If not found
}
