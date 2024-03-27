import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ble/data/device_model.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceScreen extends StatefulWidget {
  const DeviceScreen({super.key});

  @override
  _DeviceScreenState createState() => _DeviceScreenState();
}

class _DeviceScreenState extends State<DeviceScreen>
    with SingleTickerProviderStateMixin {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> allDevicesList = <BluetoothDevice>[];
  List<BluetoothDevice> onlyBLEDevicesList = <BluetoothDevice>[];
  late List<DeviceModel> devices = <DeviceModel>[];
  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    _scanDevices();
    Timer.periodic(const Duration(seconds: 5), (timer) {
      _scanDevices();
    });
  }

  void _scanDevices() {
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      devices.clear();

      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
        DeviceModel deviceModel = DeviceModel(
          result.device.name,
          result.device.id.toString(),
          result.rssi,
        );
        devices.add(deviceModel);
      }
    });
    _restartScan();
  }

  void _restartScan() {
    flutterBlue.stopScan();
    flutterBlue.startScan();
  }

  _addDeviceTolist(final BluetoothDevice device) {
    if (!allDevicesList.contains(device)) {
      setState(() {
        allDevicesList.add(device);
        if (device.type == BluetoothDeviceType.le) {
          onlyBLEDevicesList.add(device);
        }
      });
    }
  }

  Widget _buildListViewOfDevices(List<BluetoothDevice> devices) {
    List<Widget> containers = <Widget>[];

    for (BluetoothDevice device in devices) {
      containers.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 120,
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bluetooth),
                        Text(
                          device.name == ''
                              ? "Device name: (unknown device)"
                              : "Device name: ${device.name}",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight
                                .bold, // Example: You can adjust font weight
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: 8), // Example: Adding some vertical spacing
                  ],
                ),
                Text(
                  "Device ID: ${device.id}",
                  style: const TextStyle(
                    fontSize: 20,
                    fontStyle: FontStyle.italic, // Example: Adding italic style
                  ),
                ),
                StreamBuilder<List<ScanResult>>(
                  stream: flutterBlue.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Colors
                              .red, // Example: Changing text color for error
                        ),
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
                          style: const TextStyle(
                            fontSize: 20,
                            color: Colors.green, // Example: Changing text color
                          ),
                        );
                      }
                    }

                    return const Text(
                      'RSSI: ...',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.grey, // Example: Changing text color
                      ),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'BLE only ',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Checkbox(
                activeColor: Colors.blueGrey,
                value: isChecked,
                onChanged: (value) {
                  setState(() {
                    isChecked = value!;
                  });
                },
              )
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: isChecked
                ? _buildListViewOfDevices(onlyBLEDevicesList)
                : _buildListViewOfDevices(allDevicesList),
          ),
        ],
      ),
    );
  }
}
