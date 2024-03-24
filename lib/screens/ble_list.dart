import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEListScreen extends StatefulWidget {
  BLEListScreen({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  BLEListScreenState createState() => BLEListScreenState();
}

class BLEListScreenState extends State<BLEListScreen> {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};
  final _writeController = TextEditingController();
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  _addDeviceTolist(final BluetoothDevice device) {
    if (!devicesList.contains(device) && device.name.toString() == "Kontakt") {
      setState(() {
        devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in devicesList) {
      print(device.id.toString());
      containers.add(
        SizedBox(
          height: 120,
          child: Row(
            children: <Widget>[
              Expanded(
                child: Column(
                  children: <Widget>[
                    Text(device.name == '' ? '(unknown device)' : device.name),
                    Text(device.id.toString()),
                    StreamBuilder<List<ScanResult>>(
                      stream: flutterBlue.scanResults,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          List<ScanResult> scanResults = snapshot.data!;
                          ScanResult? scanResult = scanResults.firstWhere(
                            (result) => result.device.id == device.id,
                            // orElse: () => ScanResult(device: device, rssi: 0),
                          );
                          return Text('RSSI: ${scanResult.rssi.toString()}');
                        }
                        return const Text('RSSI: N/A');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  ListView _buildView() {
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: _buildView(),
      );
}
