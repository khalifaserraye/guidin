class DeviceModel {
  String _name;
  String _id;
  String _rssi;

  DeviceModel(this._name, this._id, this._rssi);

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  String get id => _id;

  set id(String value) {
    _id = value;
  }

  String get rssi => _rssi;

  set rssi(String value) {
    _rssi = value;
  }
}
