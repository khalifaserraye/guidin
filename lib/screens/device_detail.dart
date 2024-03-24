import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BLEListScreen extends StatefulWidget {
  BLEListScreen({Key? key}) : super(key: key);

  final FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  final List<BluetoothDevice> devicesList = <BluetoothDevice>[];
  final Map<Guid, List<int>> readValues = <Guid, List<int>>{};

  @override
  BLEListScreenState createState() => BLEListScreenState();
}

class BLEListScreenState extends State<BLEListScreen> {
  final _writeController = TextEditingController();
  BluetoothDevice? _connectedDevice;
  List<BluetoothService> _services = [];

  _addDeviceTolist(final BluetoothDevice device) {
    if (!widget.devicesList.contains(device)) {
      setState(() {
        widget.devicesList.add(device);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    widget.flutterBlue.connectedDevices
        .asStream()
        .listen((List<BluetoothDevice> devices) {
      for (BluetoothDevice device in devices) {
        _addDeviceTolist(device);
      }
    });
    widget.flutterBlue.scanResults.listen((List<ScanResult> results) {
      for (ScanResult result in results) {
        _addDeviceTolist(result.device);
      }
    });
    widget.flutterBlue.startScan();
  }

  ListView _buildListViewOfDevices() {
    List<Widget> containers = <Widget>[];
    for (BluetoothDevice device in widget.devicesList) {
      // if (true) {
      if (device.type.toString() == "BluetoothDeviceType.le") {
        containers.add(
          SizedBox(
            height: 110,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(device.name == '' ? '(unknown device)' : device.name),
                Text(device.id.toString()),
                StreamBuilder<List<ScanResult>>(
                  stream: widget.flutterBlue.scanResults,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      List<ScanResult> scanResults = snapshot.data!;
                      for (ScanResult scanResult in scanResults) {
                        if (scanResult.device.id == device.id) {
                          return Text('RSSI: ${scanResult.rssi.toString()}');
                        }
                      }
                    }
                    return const Text('RSSI: N/A');
                  },
                ),
                TextButton(
                  child: const Text(
                    'Connect',
                    style: TextStyle(color: Colors.green),
                  ),
                  onPressed: () async {
                    widget.flutterBlue.stopScan();
                    try {
                      await device.connect();
                    } on PlatformException catch (e) {
                      if (e.code != 'already_connected') {
                        rethrow;
                      }
                    } finally {
                      _services = await device.discoverServices();
                    }
                    setState(() {
                      _connectedDevice = device;
                    });
                  },
                ),
              ],
            ),
          ),
        );
      }
    }

    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        ...containers,
      ],
    );
  }

  // List<ButtonTheme> _buildReadWriteNotifyButton(
  //     BluetoothCharacteristic characteristic) {
  //   List<ButtonTheme> buttons = <ButtonTheme>[];

  //   if (characteristic.properties.read) {
  //     buttons.add(
  //       ButtonTheme(
  //         minWidth: 10,
  //         height: 20,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4),
  //           child: TextButton(
  //             child: const Text('READ', style: TextStyle(color: Colors.yellow)),
  //             onPressed: () async {
  //               var sub = characteristic.value.listen((value) {
  //                 setState(() {
  //                   widget.readValues[characteristic.uuid] = value;
  //                 });
  //               });
  //               await characteristic.read();
  //               sub.cancel();
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   if (characteristic.properties.write) {
  //     buttons.add(
  //       ButtonTheme(
  //         minWidth: 10,
  //         height: 20,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4),
  //           child: ElevatedButton(
  //             child: const Text('WRITE', style: TextStyle(color: Colors.red)),
  //             onPressed: () async {
  //               await showDialog(
  //                   context: context,
  //                   builder: (BuildContext context) {
  //                     return AlertDialog(
  //                       title: const Text("Write"),
  //                       content: Row(
  //                         children: <Widget>[
  //                           Expanded(
  //                             child: TextField(
  //                               controller: _writeController,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       actions: <Widget>[
  //                         TextButton(
  //                           child: const Text("Send"),
  //                           onPressed: () {
  //                             characteristic.write(
  //                                 utf8.encode(_writeController.value.text));
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                         TextButton(
  //                           child: const Text("Cancel"),
  //                           onPressed: () {
  //                             Navigator.pop(context);
  //                           },
  //                         ),
  //                       ],
  //                     );
  //                   });
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //   }
  //   if (characteristic.properties.notify) {
  //     buttons.add(
  //       ButtonTheme(
  //         minWidth: 10,
  //         height: 20,
  //         child: Padding(
  //           padding: const EdgeInsets.symmetric(horizontal: 4),
  //           child: ElevatedButton(
  //             child:
  //                 const Text('NOTIFY', style: TextStyle(color: Colors.black)),
  //             onPressed: () async {
  //               characteristic.value.listen((value) {
  //                 setState(() {
  //                   widget.readValues[characteristic.uuid] = value;
  //                 });
  //               });
  //               await characteristic.setNotifyValue(true);
  //             },
  //           ),
  //         ),
  //       ),
  //     );
  //   }

  //   return buttons;
  // }

  // ListView _buildConnectDeviceView() {
  //   List<Widget> containers = <Widget>[];

  //   for (BluetoothService service in _services) {
  //     List<Widget> characteristicsWidget = <Widget>[];

  //     for (BluetoothCharacteristic characteristic in service.characteristics) {
  //       characteristicsWidget.add(
  //         Align(
  //           alignment: Alignment.centerLeft,
  //           child: Column(
  //             children: <Widget>[
  //               Row(
  //                 children: <Widget>[
  //                   Text(characteristic.uuid.toString(),
  //                       style: const TextStyle(fontWeight: FontWeight.bold)),
  //                 ],
  //               ),
  //               Row(
  //                 children: <Widget>[
  //                   ..._buildReadWriteNotifyButton(characteristic),
  //                 ],
  //               ),
  //               Row(
  //                 children: <Widget>[
  //                   Text('Value: ${widget.readValues[characteristic.uuid]}'),
  //                 ],
  //               ),
  //               const Divider(),
  //             ],
  //           ),
  //         ),
  //       );
  //     }
  //     containers.add(
  //       ExpansionTile(
  //           title: Text(service.uuid.toString()),
  //           children: characteristicsWidget),
  //     );
  //   }

  //   return ListView(
  //     padding: const EdgeInsets.all(8),
  //     children: <Widget>[
  //       ...containers,
  //     ],
  //   );
  // }

  ListView _buildView() {
    if (_connectedDevice != null) {
      // return _buildConnectDeviceView();
    }
    return _buildListViewOfDevices();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: _buildView(),
      );
}
