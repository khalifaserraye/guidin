// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ble/screens/device_model.dart';
import 'package:flutter_ble/web_service/web_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:animated_icon/animated_icon.dart';

class GuidanceScreen extends StatefulWidget {
  const GuidanceScreen({super.key});

  @override
  _GuidanceScreenState createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends State<GuidanceScreen>
    with SingleTickerProviderStateMixin {
  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> allDevicesList = <BluetoothDevice>[];
  List<BluetoothDevice> onlyBLEDevicesList = <BluetoothDevice>[];
  int direction = 0;
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
      int newDirection = WebService().getDirectionAngle(devices);

      setState(() {
        direction = newDirection;
      });
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

  // double _getAngleForDirection(String direction) {
  //   switch (direction) {
  //     case forward:
  //       return 0.0;
  //     case right:
  //       return pi / 2; // 90 degrees
  //     case backward:
  //       return pi; // 180 degrees
  //     case left:
  //       return -pi / 2; // -90 degrees
  //   }
  // }

  double convertAngle(double angle) {
    switch (angle) {
      case 0:
        return 0.0;
      case 90:
        return pi / 2;
      case 180:
        return pi;
      case (-90):
        return -pi / 2;
      default:
        return 0;
    }
  }

  String getDirectionName(int angle) {
    if (angle == 90) {
      return 'Turn right';
    } else if (angle == 180)
      return 'Turn around';
    else if (angle == -90)
      return 'Turn left';
    else
      return 'Continue straight';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueGrey,
        title: const Text(
          'Guidance',
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
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Text(
            getDirectionName(direction).toString(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          AnimatedArrow(
            angle: direction * (pi / 180),
          ),
        ],
      ),
    );
  }
}

class AnimatedArrow extends StatefulWidget {
  final double angle;

  const AnimatedArrow({Key? key, required this.angle}) : super(key: key);

  @override
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  bool isArrowShown = false;

  @override
  void initState() {
    super.initState();
    // Toggle the visibility of the arrow every 500 milliseconds
    Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        isArrowShown = !isArrowShown;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        height: 500,
        child: Transform.rotate(
          angle: widget.angle - pi / 2,
          child: isArrowShown
              ? const Icon(Icons.arrow_forward, size: 220)
              : SizedBox.shrink(), // Hide arrow when not shown
        ),
      ),
    );
  }
}
