// ignore_for_file: library_private_types_in_public_api, curly_braces_in_flow_control_structures

import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_ble/data/device_model.dart';
import 'package:flutter_ble/web_service/web_service.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

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
  int directionAngle = -1;
  late List<DeviceModel> devices = <DeviceModel>[];
  final List<String> places = [
    'Information Desk',
    'Elevators',
    'Escalators',
    'ATM',
    'Toilets',
    'Parking',
    'Food Court',
    'Restaurants',
    'Cinema',
    'Play Area',
    'Retail Stores',
  ];
  bool placeSelected = false;
  String? destination;

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
        directionAngle = newDirection;
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

  String getDirectionName(int angle) {
    if (angle == 0) return 'Continue straight';
    if (angle == 90)
      return 'Turn right';
    else if (angle == 180)
      return 'Turn around';
    else if (angle == -90)
      return 'Turn left';
    else
      return 'Wait';
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
      body: placeSelected
          ? (directionAngle == -1 ? buildWaitingDirection() : buildDirection())
          : buildPlaceDropdownButton(places),
    );
  }

  Widget buildPlaceDropdownButton(List<String> places) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Select a place',
          style: TextStyle(
            fontSize: 30,
            color: Colors.blueGrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueGrey, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButton<String>(
              iconSize: 40,
              value: null,
              onChanged: (String? newValue) {
                setState(() {
                  placeSelected = true;
                  destination = newValue!;
                });
              },
              items: places.map((String place) {
                return DropdownMenuItem<String>(
                  value: place,
                  child: Text(place),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Column buildDirection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: <TextSpan>[
              const TextSpan(
                text: 'Going to ',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                ),
              ),
              TextSpan(
                text: destination,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.blueGrey,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        AnimatedArrow(
          angle: directionAngle * (pi / 180),
        ),
        Text(
          getDirectionName(directionAngle).toString(),
          style: const TextStyle(
            fontSize: 40,
            color: Colors.blueGrey,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Center buildWaitingDirection() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: CircularProgressIndicator(
              strokeWidth: 12,
              backgroundColor: Colors.blueGrey,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
          SizedBox(height: 40),
          Text(
            "Getting direction ...",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedArrow extends StatefulWidget {
  final double angle;

  const AnimatedArrow({super.key, required this.angle});

  @override
  _AnimatedArrowState createState() => _AnimatedArrowState();
}

class _AnimatedArrowState extends State<AnimatedArrow>
    with SingleTickerProviderStateMixin {
  bool isArrowShown = false;

  @override
  void initState() {
    super.initState();
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
              ? const Icon(
                  Icons.arrow_forward,
                  size: 220,
                  color: Colors.blueGrey,
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }
}
