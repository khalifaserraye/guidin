// ignore_for_file: avoid_print, library_private_types_in_public_api

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ble/screens/device_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DirectionScreen extends StatefulWidget {
  const DirectionScreen({super.key});

  @override
  _DirectionScreenState createState() => _DirectionScreenState();
}

class _DirectionScreenState extends State<DirectionScreen>
    with SingleTickerProviderStateMixin {
  int rssi = -1000;
  final String forward = "E1:DC:0C:14:69:75";
  final String backward = "EC:29:A0:D7:8D:EA";
  final String right = "E0:E2:41:1A:85:F2";
  final String left = "D6:DA:4D:6B:F9:C1";
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  String nearestDeviceId = "";
  List<DeviceModel> devices = <DeviceModel>[];
  DeviceModel deviceWithMaxRssi = DeviceModel("_name", "_id", -1000);
  @override
  void initState() {
    super.initState();
    flutterBlue.startScan();
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        if (result.device.name == "Kontakt") {
          _addDeviceTolist(result.device);
          setState(() {
            int newRSSI = result.rssi;
            // if (newRSSI > rssi) {
            rssi = newRSSI;
            nearestDeviceId = result.device.id.toString();
            // }
          });
        }
      }
    });
    Timer.periodic(const Duration(seconds: 3), (timer) {
      print("------------------  Device list: ${devicesList.length}");
      flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          if (result.device.name == "Kontakt") {
            _addDeviceTolist(result.device);
            DeviceModel deviceModel = DeviceModel(
                result.device.name, result.device.id.toString(), result.rssi);
            devices.add(deviceModel);
            setState(() {
              int newRSSI = result.rssi;
              // if (newRSSI > rssi) {
              rssi = newRSSI;
              nearestDeviceId = result.device.id.toString();
              // }
            });
          }
        }
      });
      setState(() {
        deviceWithMaxRssi = devices.reduce(
            (current, next) => current.rssi > next.rssi ? current : next);
      });

      _restartScan();
    });
  }

  void _restartScan() {
    flutterBlue.stopScan();
    flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  Future<int?> getRSSIbyBLEid(String deviceId) async {
    try {
      List<ScanResult> scanResults = await flutterBlue.scanResults.first;
      ScanResult? scanResult = scanResults.firstWhere(
        (result) => result.device.id.toString() == deviceId,
        // orElse: () => null,
      );
      return scanResult.rssi;
    } catch (e) {
      print('Error occurred: $e');
      return null; // or handle the error as per your requirement
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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'nearestDeviceId ${deviceWithMaxRssi.id}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Expanded(
            // Wrap ListView with Expanded
            child: _buildListViewOfDevices(),
          ),
        ],
      ),
    );
  }
}
