import 'package:flutter/material.dart';
import 'package:flutter_ble/screens/guidance.dart';
import 'package:flutter_ble/screens/home.dart';
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
        home: HomeScreen(),
      );
}

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';

// void main() async {
//   // Ensure that plugin services are initialized before 'runApp()'
//   WidgetsFlutterBinding.ensureInitialized();

//   // Obtain a list of the available cameras on the device
//   final cameras = await availableCameras();

//   // Get a specific camera from the list of available cameras
//   final firstCamera = cameras.first;

//   runApp(CameraApp(camera: firstCamera));
// }

// class CameraApp extends StatelessWidget {
//   final CameraDescription camera;

//   const CameraApp({
//     Key? key,
//     required this.camera,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Camera App'),
//         ),
//         body: CameraScreen(camera: camera),
//       ),
//     );
//   }
// }

// class CameraScreen extends StatefulWidget {
//   final CameraDescription camera;

//   const CameraScreen({
//     Key? key,
//     required this.camera,
//   }) : super(key: key);

//   @override
//   _CameraScreenState createState() => _CameraScreenState();
// }

// class _CameraScreenState extends State<CameraScreen> {
//   late CameraController _controller;
//   late Future<void> _initializeControllerFuture;

//   @override
//   void initState() {
//     super.initState();
//     // Create a CameraController
//     _controller = CameraController(
//       // Get the specific camera from widget.camera
//       widget.camera,
//       // Define the resolution to use
//       ResolutionPreset.medium,
//     );

//     // Initialize the controller
//     _initializeControllerFuture = _controller.initialize();
//   }

//   @override
//   void dispose() {
//     // Dispose of the controller when the widget is disposed
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<void>(
//       future: _initializeControllerFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.done) {
//           // If the Future is complete, display the preview
//           return Center(
//             child: Stack(children: [
//               CameraPreview(_controller),
//               Center(child: AnimatedArrow(angle: 180))
//             ]),
//           );
//         } else {
//           // Otherwise, display a loading indicator
//           return Center(
//             child: CircularProgressIndicator(),
//           );
//         }
//       },
//     );
//   }
// }

// class AnimatedArrow extends StatefulWidget {
//   final double angle;

//   const AnimatedArrow({Key? key, required this.angle}) : super(key: key);

//   @override
//   _AnimatedArrowState createState() => _AnimatedArrowState();
// }

// class _AnimatedArrowState extends State<AnimatedArrow>
//     with SingleTickerProviderStateMixin {
//   bool isArrowShown = false;

//   @override
//   void initState() {
//     super.initState();
//     // Toggle the visibility of the arrow every 500 milliseconds
//     Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       setState(() {
//         isArrowShown = !isArrowShown;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 500,
//       child: Transform.rotate(
//         angle: widget.angle,
//         child: isArrowShown
//             ? const Icon(Icons.arrow_forward, size: 220)
//             : SizedBox.shrink(), // Hide arrow when not shown
//       ),
//     );
//   }
// }
