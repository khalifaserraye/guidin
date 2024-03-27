import 'package:flutter_ble/data/device_model.dart';

class WebService {
  int getDirectionAngle(List<DeviceModel> devices) {
    const String forward = "E1:DC:0C:14:69:75";
    const String backward = "EC:29:A0:D7:8D:EA";
    const String right = "E0:E2:41:1A:85:F2";
    const String left = "D6:DA:4D:6B:F9:C1";

    int getAngle(String deviceId) {
      switch (deviceId) {
        case forward:
          return 0;
        case backward:
          return 180;
        case right:
          return 90;
        case left:
          return -90;
        default:
          return 0;
      }
    }

    List<String> myDevices = [forward, backward, right, left];
    DeviceModel result = devices
        .where((result) => myDevices.contains(result.id.toString()))
        .reduce((currentMax, result) =>
            result.rssi > currentMax.rssi ? result : currentMax);
    int direction = getAngle(result.id.toString());
    return direction;
  }
}
