import 'dart:convert';

/// Represents metadata and identification for a physical sensor device.
class SensorData {
  final String id;         // e.g., BLE MAC address or UUID
  final String name;       // e.g., "SensorPush HT.w"
  final Uri uri;           // e.g., sensor://ble/htw/abcd1234
  final Map<String, dynamic> metadata; // arbitrary metadata (e.g., calibration, battery status)

  SensorData({
    required this.id,
    required this.name,
    required this.uri,
    required this.metadata,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['id'],
      name: json['name'],
      uri: Uri.parse(json['uri']),
      metadata: jsonDecode(json['metadata'] ?? '{}'),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'uri': uri.toString(),
    'metadata': jsonEncode(metadata),
  };

  @override
  String toString() => 'SensorData($name at $uri)';
}