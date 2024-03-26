// ignore_for_file: avoid_print, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum Direction { forward, backward, right, left }

class Guidage extends StatefulWidget {
  const Guidage({super.key});

  @override
  _GuidageState createState() => _GuidageState();
}

class _GuidageState extends State<Guidage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  Direction _currentDirection = Direction.backward;
  final String forward = "E1:DC:0C:14:69:75";
  final String backward = "EC:29:A0:D7:8D:EA";
  final String right = "E0:E2:41:1A:85:F2";
  final String left = "D6:DA:4D:6B:F9:C1";
  int rssi = -1000;
  String nearestDeviceId = "";

  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  // final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device) && device.name.toString() == "Kontakt") {
      setState(() async {
        devicesList.add(device);
        int deviceRssi = (await getRSSIbyBLEid(device.id.toString())) as int;
        if (deviceRssi < rssi) {
          nearestDeviceId = device.id.toString();
        }
      });
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   flutterBlue.connectedDevices
  //       .asStream()
  //       .listen((List<BluetoothDevice> devices) {
  //     for (BluetoothDevice device in devices) {
  //       _addDeviceTolist(device);
  //     }
  //   });
  //   flutterBlue.scanResults.listen((List<ScanResult> results) {
  //     for (ScanResult result in results) {
  //       _addDeviceTolist(result.device);
  //     }
  //   });
  //   flutterBlue.startScan();
  //   super.initState();
  //   _controller = AnimationController(
  //     vsync: this,
  //     duration: const Duration(seconds: 1),
  //   );

  //   // Start updating direction every second
  //   Timer.periodic(const Duration(seconds: 1), (_) {
  //     setState(() {
  //       _currentDirection = _getNextDirection(right);
  //     });
  //   });

  //   _controller.repeat(reverse: true);
  // }

  @override
  void initState() {
    super.initState();
    flutterBlue.startScan();
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    Timer.periodic(const Duration(seconds: 5), (timer) {
      print("------------------  Device list: ${devicesList.length}");
      flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          _addDeviceTolist(result.device);
        }
        setState(() {
          _currentDirection = _getNextDirection(nearestDeviceId);
        });
      });
      _restartScan();
    });
  }

  void _restartScan() {
    flutterBlue.stopScan();
    flutterBlue.startScan();
  }

  Future<String?> getRSSIbyBLEid(String deviceId) async {
    try {
      List<ScanResult> scanResults = await flutterBlue.scanResults.first;
      ScanResult? scanResult = scanResults.firstWhere(
        (result) => result.device.id.toString() == deviceId,
        // orElse: () => null,
      );
      return scanResult.rssi.toString();
    } catch (e) {
      print('Error occurred: $e');
      return null; // or handle the error as per your requirement
    }
  }

  Direction _getNextDirection(String deviceId) {
    print("$deviceId  $right");
    if (forward == deviceId) {
      return Direction.forward;
    } else if (backward == deviceId)
      return Direction.backward;
    else if (right == deviceId)
      return Direction.right;
    else if (left == deviceId)
      return Direction.left;
    else
      return Direction.forward;
  }

  double _getAngleForDirection(Direction direction) {
    print(direction);
    switch (direction) {
      case Direction.forward:
        return 0.0;
      case Direction.right:
        return pi / 2; // 90 degrees
      case Direction.backward:
        return pi; // 180 degrees
      case Direction.left:
        return -pi / 2; // -90 degrees
    }
  }

  List<String> places = [
    'Market',
    'Toilet',
    'Parking',
    'Restaurant',
    'Cinema',
    'ATM',
    'Pharmacy',
    'Clothing Store'
  ];
  String _selectedPlace = 'Market';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Guidage',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DropdownButton<String>(
              value: _selectedPlace,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPlace = newValue!;
                });
              },
              items: places.map((String place) {
                return DropdownMenuItem<String>(
                  value: place,
                  child: Text(place),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            Text(
              _getDirectionName(_currentDirection),
              style: TextStyle(fontSize: 40),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _getDirectionName(Direction direction) {
    switch (direction) {
      case Direction.forward:
        return 'continue straight';
      case Direction.backward:
        return 'turn around';
      case Direction.right:
        return 'turn right';
      case Direction.left:
        return 'turn left';
      default:
        return 'continue straight'; // Default to continue straight if no match found
    }
  }
}
