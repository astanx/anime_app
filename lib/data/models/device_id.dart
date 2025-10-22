class DeviceID {
  final String id;
  DeviceID({required this.id});
  factory DeviceID.fromJson(Map<String, dynamic> json) {
    return DeviceID(id: json['id']);
  }
}
