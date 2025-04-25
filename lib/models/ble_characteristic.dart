// lib/models/ble_characteristic.dart

class BleCharacteristic {
  final String uuid;          // raw UUID string
  final String name;          // optional descriptive name
  final List<String> capabilities; // e.g., ['read', 'write', 'notify']

  BleCharacteristic({
    required this.uuid,
    required this.name,
    required this.capabilities,
  });

  @override
  String toString() => '$name (${capabilities.join(', ')})';
}