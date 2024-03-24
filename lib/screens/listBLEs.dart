import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum Direction { forward, backward, right, left }

class Devices extends StatefulWidget {
  const Devices({super.key});

  @override
  _DevicesState createState() => _DevicesState();
}

class _DevicesState extends State<Devices> with SingleTickerProviderStateMixin {
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
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

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
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Start updating direction every second
    Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _currentDirection = _getNextDirection(right);
      });
    });

    _controller.repeat(reverse: true);
  }

// String getNearestBLE(){

//   return
// }

  Direction _getNextDirection(String deviceId) {
    print(deviceId + "  " + right);
    if (forward == deviceId)
      return Direction.forward;
    else if (backward == deviceId)
      return Direction.backward;
    else if (right == deviceId)
      return Direction.right;
    else if (left == deviceId)
      return Direction.left;
    else
      return Direction.forward; // Default to forward if no match found
  }

  Future<String?> getRSSIbyBLEid(String deviceId) async {
    List<ScanResult> scanResults = await flutterBlue.scanResults.first;
    ScanResult? scanResult = scanResults.firstWhere(
      (result) => result.device.id.toString() == deviceId,
      // orElse: () => null,
    );
    return scanResult.rssi.toString();
  }

  Expanded _buildListViewOfDevices() {
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

                          if (scanResult.rssi >= rssi) {
                            rssi = scanResult.rssi;
                            nearestDeviceId = device.id.toString();
                          }
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

    return Expanded(
      child: ListView(
        padding: const EdgeInsets.all(8),
        children: <Widget>[
          ...containers,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Direction'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(
              width: 200,
              height: 200,
              child: Transform.rotate(
                angle: _getAngleForDirection(_currentDirection),
                child: CustomPaint(
                  size: Size(200, 200), // Explicitly specify the size
                  painter: ArrowPainter(),
                ),
              ),
            ),
            _buildListViewOfDevices(),
          ],
        ),
        // ],
      ),
    );
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class ArrowPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double arrowWidth = size.width * 0.1;
    final double arrowLength = size.height * 0.8;

    final Paint paint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(-arrowWidth / 2, arrowLength);
    path.lineTo(arrowWidth / 2, arrowLength);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
