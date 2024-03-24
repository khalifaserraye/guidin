import 'dart:async';

import 'package:flutter/foundation.dart';
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
  String? _rssiValue = "";
  String nearestDeviceId = "";

  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];

  @override
  void initState() {
    super.initState();
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    // Timer.periodic(Duration(seconds: 5), (timer) {
    //   devicesList.clear();
    //   flutterBlue.scanResults.listen((List<ScanResult> results) {
    //     for (ScanResult result in results) {
    //       _addDeviceTolist(result.device);
    //     }
    //   });

    //   flutterBlue.startScan();
    //   // Call the function to fetch RSSI value
    //   getRSSIAndUpdateUI("D6:DA:4D:6B:F9:C1");
    // });
    flutterBlue.startScan();
  }

  // Function to fetch RSSI value and update UI
  Future<void> getRSSIAndUpdateUI(String bleId) async {
    try {
      final String? rssiValue = await getRSSIbyBLEid(bleId);
      // Update the UI only if the widget is still mounted
      if (mounted) {
        setState(() {
          _rssiValue = rssiValue;
        });
      }
    } catch (e) {
      print('Error fetching RSSI: $e');
    }
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device)) {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  Expanded _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in devicesList) {
      if (kDebugMode) {
        print(device.id.toString());
      }
      containers.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 120,
            child: Expanded(
              child: Column(
                children: <Widget>[
                  Text(
                    device.name == ''
                        ? "Device name: (unknown device)"
                        : "Device name: ${device.name}",
                    style: const TextStyle(fontSize: 20),
                  ),
                  StreamBuilder<List<ScanResult>>(
                    stream: flutterBlue.scanResults,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<ScanResult> scanResults = snapshot.data!;
                        ScanResult? scanResult = scanResults.firstWhere(
                          (result) => result.device.id == device.id,
                        );

                        print(scanResult);

                        // if (scanResult.rssi >= rssi) {
                        //   rssi = scanResult.rssi;
                        //   nearestDeviceId = device.id.toString();
                        // }
                        return Text(
                          'RSSI: ${scanResult.rssi.toString()}',
                          style: const TextStyle(fontSize: 20),
                        );
                      }
                      return const Text(
                        'RSSI: N/A',
                        style: TextStyle(fontSize: 20),
                      );
                    },
                  ),
                  Text(
                    "Device ID: ${device.id}",
                    style: const TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          ...containers,
        ],
      ),
    );
  }

  Future<String?> getRSSIbyBLEid(String deviceId) async {
    List<ScanResult> scanResults = await flutterBlue.scanResults.first;
    ScanResult? scanResult = scanResults.firstWhere(
      (result) => result.device.id.toString() == deviceId,
      // orElse: () => null,
    );
    return scanResult.rssi.toString();
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
        child: Column(
          children: [
            Text(_rssiValue!),
            FutureBuilder<String?>(
              future: getRSSIbyBLEid("D6:DA:4D:6B:F9:C1"),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While data is being fetched, show a loading indicator
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.hasError) {
                    // If there's an error, display an error message
                    return Text('Error: ${snapshot.error}');
                  } else {
                    // If data is successfully fetched, display it
                    final String rssiValue = snapshot.data!;
                    return Text('RSSI Value: $rssiValue');
                  }
                }
              },
            ),
            _buildListViewOfDevices(),
          ],
        ),
        // ],
      ),
    );
  }
}
