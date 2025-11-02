import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import './../bluetooth_helpers.dart';
import '../bluetooth/device_manager.dart';
import '../data/sensor_cmd_id.dart';
import 'package:sqflite/sqflite.dart';
import '../main.dart';

// TODO: does not connect correctly to new devices
class DebugPage extends ConsumerWidget {
  const DebugPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final db = ref.read(appDatabase);
    final devices = ref.watch(deviceManagerProvider.select((s) => s.allDevices));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Connected Devices: ${devices.length}'),
            const SizedBox(height: 20),
            ...devices.map((device) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () {
                  writeToSensor(
                    db,
                    BluetoothDevice.fromId(device.deviceId),
                    SensorCmdId.testPump,
                    1,
                  );
                  print("you pressed");
                },
                child: Text('Test Pump - ${device.deviceId}'),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}


