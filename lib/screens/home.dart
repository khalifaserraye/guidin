import 'package:flutter/material.dart';
import 'package:flutter_ble/screens/devices.dart';
import 'package:flutter_ble/screens/guidage.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'GuidIn',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Devices()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Match the AppBar color
              ),
              child: Text(
                'Liste des balises BLE',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
            SizedBox(height: 20), // Add some spacing between buttons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Guidage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey, // Match the AppBar color
              ),
              child: Text(
                'Guidage',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
            ),
          ],
        ),
      ),
    );
  }
}
