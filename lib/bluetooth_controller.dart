import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class MyBluetooth extends StatefulWidget {
  final Database database;
  final bool onAddDevice;
  final bool exitAddPlant;
  const MyBluetooth({
    super.key,
    required this.database,
    required this.onAddDevice,
    required this.exitAddPlant,
  });

  @override
  State<MyBluetooth> createState() => _MyBluetoothState();
}

class _MyBluetoothState extends State<MyBluetooth> {
  // TODO: database should save devices to be used here i think..
  @override
  void initState() {
    super.initState();
    initializeBluetooth();
    // move this function to initializeBluetooth?
    scanResults(); // Automatically starts scanning when MyBluetooth is started
  }

  Future<void> addDevice() async {
    if (_value != null) {
      var selectedDevice = devices[_value!];
      // TODO: save to database
      // connect to device
      connectToDevice(selectedDevice.device);
      print("connected to $selectedDevice.advertisementData.advName");
    }
  }

  // TODO: should not connect again after once connected, only if disconnect
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
        setState(() {
          devices.add(r);
        });
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
  int? _value = 0;
  List<ScanResult> devices = [];

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
                label: Text(devices[index].advertisementData.advName),
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
