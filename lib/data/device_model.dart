class DeviceModel {
  String _name;
  String _id;
  int _rssi;

  DeviceModel(this._name, this._id, this._rssi);

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  int get rssi => _rssi;

  set rssi(int value) {
    _rssi = value;
  }
}
