import 'package:flutter/material.dart';
import 'package:flutter_ble/screens/devices.dart';
import 'package:flutter_ble/screens/direction.dart';
import 'package:flutter_ble/screens/guidage.dart';
// import 'package:flutter_ble/screens/home.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'BLE De  mo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const DirectionScreen(),
      );
}
