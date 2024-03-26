// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum Direction { forward, backward, right, left }

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  _DevicesState createState() => _DevicesState();
}

class _DevicesState extends State<Devices> with SingleTickerProviderStateMixin {
  int rssi = -1000;
  Direction _currentDirection = Direction.forward;
  final String forward = "E1:DC:0C:14:69:75";
  final String backward = "EC:29:A0:D7:8D:EA";
  final String right = "E0:E2:41:1A:85:F2";
  final String left = "D6:DA:4D:6B:F9:C1";
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  @override
  void initState() {
    super.initState();
    flutterBlue.startScan();
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    Timer.periodic(const Duration(seconds: 10), (timer) {
      print("------------------  Device list: ${devicesList.length}");
      flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          _addDeviceTolist(result.device);
        }
      });
      _restartScan();
    });
  }

  void _restartScan() {
    flutterBlue.stopScan();
    flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device) && device.name == "Kontakt") {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in devicesList) {
      containers.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 120,
            child: Column(
              children: <Widget>[
                Text(
                  device.name == ''
                      ? "Device name: (unknown device)"
                      : "Device name: ${device.name}",
                  style: const TextStyle(fontSize: 20),
                ),
                Text(
                  "Device ID: ${device.id}",
                  style: const TextStyle(fontSize: 20),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: flutterBlue.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(fontSize: 20),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }

                    if (snapshot.hasData) {
                      List<ScanResult> scanResults = snapshot.data!;
                      ScanResult? scanResult;
                      try {
                        scanResult = scanResults.firstWhere(
                          (result) => result.device.id == device.id,
                          orElse: () {
                            // print('No matching element.');
                            return scanResult!;
                          },
                        );
                      } catch (e) {
                        // print("Device not found in scan results: $e");
                      }

                      if (scanResult != null) {
                        return Text(
                          'RSSI: ${scanResult.rssi.toString()}',
                          style: const TextStyle(fontSize: 20),
                        );
                      }
                    }

                    return const Text(
                      'RSSI: ...',
                      style: TextStyle(fontSize: 20),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: containers,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Devices',
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
        child: _buildListViewOfDevices(),
      ),
    );
  }
}
