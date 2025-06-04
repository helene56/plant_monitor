import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';


// TODO:
// 1. start scanning for devices when add floating button is clicked
// 2. all devices with certain id (to be determined later) should be showed in the list availible
//    to choose in choice chip select
// 3. connect to device that has been selected

class _MyBluState extends StatefulWidget {
  const _MyBluState({super.key});

  @override
  State<_MyBluState> createState() => __MyBluStateState();
}

class __MyBluStateState extends State<_MyBluState> {
  // TODO: database should save devices to be used here i think..


    Future<void> initializeBluetooth() async {
        // set log level
        // if your terminal doesn't support color you'll see annoying logs like `\x1B[1;35m`
        FlutterBluePlus.setLogLevel(LogLevel.verbose, color:false);
        // first, check if bluetooth is supported by your hardware
        // Note: The platform is initialized on the first call to any FlutterBluePlus method.
        if (await FlutterBluePlus.isSupported == false) {
            print("Bluetooth not supported by this device");
            return;
        }

        // handle bluetooth on & off
        // note: for iOS the initial state is typically BluetoothAdapterState.unknown
        // note: if you have permissions issues you will get stuck at BluetoothAdapterState.unauthorized
        var subscription = FlutterBluePlus.adapterState.listen((BluetoothAdapterState state) {
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
    // TODO: specify my own identifiers
    await FlutterBluePlus.startScan(
      withServices: [Guid("180D")], // match any of the specified services
      withNames: ["Bluno"], // *or* any of the specified names
      timeout: Duration(seconds: 15),
    );

    // wait for scanning to stop
    await FlutterBluePlus.isScanning.where((val) => val == false).first;
  }

  // Helper function, might remove later on
  Future<void> getServices(BluetoothDevice device) async {
    // Note: You must call discoverServices after every re-connection!
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      // do something with service
      // Reads all characteristics
      var characteristics = service.characteristics;
      for (BluetoothCharacteristic c in characteristics) {
        if (c.properties.read) {
          List<int> value = await c.read();
          print("printing value..");
          print(value);
        }
      }
    }
  }

  //TODO: write a specific function for this app
  Future<void> writeToLed(BluetoothDevice device) async {
    // Note: You must call discoverServices after every re-connection!
    List<BluetoothService> services = await device.discoverServices();
    for (var service in services) {
      // do something with service
      if (service.serviceUuid.toString() ==
          "00001523-1212-efde-1523-785feabcd123") {
        // Iterate through characteristics
        for (var characteristic in service.characteristics) {
          if (characteristic.characteristicUuid.toString() ==
              "00001525-1212-efde-1523-785feabcd123") {
            //   // Write to the characteristic
            //   await characteristic.write([ledState]); // Example value to turn on the LED
            //   // toggle led on/off
            //   ledState ^= 1;
            //   print("Value written to characteristic");
          }
        }
      }
    }
  }

    // example: TODO: rewrite with intention of loading devices from database
  Future<void> saveDevice() async {
    // final String remoteId = await File('/remoteId.txt').readAsString();
    // var device = BluetoothDevice.fromId(remoteId);
    // // AutoConnect is convenient because it does not "time out"
    // // even if the device is not available / turned off.
    // await device.connect(autoConnect: true);
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
