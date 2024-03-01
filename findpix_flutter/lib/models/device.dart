class DeviceReading {
  double lat;
  double long;
  double speed;
  double temp;
  bool sos;
  double acl_x;
  double acl_y;
  double acl_z;
  double gyro_x;
  double gyro_y;
  double gyro_z;
  int metalSensorValue;
  DateTime lastSeen;

  DeviceReading({
    required this.lat,
    required this.long,
    required this.speed,
    required this.temp,
    required this.sos,
    required this.acl_x,
    required this.acl_y,
    required this.acl_z,
    required this.gyro_x,
    required this.gyro_y,
    required this.gyro_z,
    required this.metalSensorValue,
    required this.lastSeen,
  });

  factory DeviceReading.fromMap(Map data) {
    return DeviceReading(
      lat: data['lat'] != null ? double.parse(data['lat']) : 0.0,
      long: data['long'] != null ? double.parse(data['long']) : 0.0,
      speed: data['speed'] != null ? data['speed'].toDouble() : 0.0,
      temp: data['temp'] != null ? data['temp'].toDouble() : 0.0,
      sos: data['sos'] ?? false,
      acl_x: data['acl_x'] != null ? data['acl_x'].toDouble() : 0.0,
      acl_y: data['acl_y'] != null ? data['acl_y'].toDouble() : 0.0,
      acl_z: data['acl_z'] != null ? data['acl_z'].toDouble() : 0.0,
      gyro_x: data['gyro_x'] != null ? data['gyro_x'].toDouble() : 0.0,
      gyro_y: data['gyro_y'] != null ? data['gyro_y'].toDouble() : 0.0,
      gyro_z: data['gyro_z'] != null ? data['gyro_z'].toDouble() : 0.0,
      metalSensorValue: data['metalSensorValue'] ?? 0,
      lastSeen: DateTime.fromMillisecondsSinceEpoch(data['ts']),
    );
  }
}
