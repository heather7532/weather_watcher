import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:weather_watcher/utils/ble_utils.dart';

typedef BleFunction = Future<dynamic> Function(Map<String, dynamic> params);

class FunctionRegistry {
  static final Map<String, BleFunction> registry = {
    'readCharacteristic': _callReadCharacteristic,
    'writeCharacteristic': _callWriteCharacteristic,
    'connectToDevice': _callConnectToDevice,
    'disconnect': _callDisconnect,
    'discoverServices': _callDiscoverServices,
  };

  static Future<dynamic> _callReadCharacteristic(Map<String, dynamic> params) async {
    return await BleUtils.readCharacteristic(
      deviceId: params['deviceId'],
      serviceUuid: Uuid.parse(params['serviceUuid']),
      characteristicUuid: Uuid.parse(params['characteristicUuid']),
      capabilities: List<String>.from(params['capabilities'] ?? []),
    );
  }

  static Future<void> _callWriteCharacteristic(Map<String, dynamic> params) async {
    return await BleUtils.writeCharacteristic(
      deviceId: params['deviceId'],
      serviceUuid: Uuid.parse(params['serviceUuid']),
      characteristicUuid: Uuid.parse(params['characteristicUuid']),
      value: List<int>.from(params['value']),
    );
  }

  static Future<void> _callConnectToDevice(Map<String, dynamic> params) async {
    return await BleUtils.connectToDevice(params['deviceId']);
  }

  static Future<void> _callDisconnect(Map<String, dynamic> params) async {
    return await BleUtils.disconnect();
  }

  static Future<List<DiscoveredService>> _callDiscoverServices(Map<String, dynamic> params) async {
    return await BleUtils.discoverServices(params['deviceId']);
  }

  /// Dynamically invokes a function by name.
  static Future<dynamic> invoke(String name, Map<String, dynamic> params) async {
    final fn = registry[name];
    if (fn == null) {
      throw Exception('❌ Function "$name" not found in registry');
    }
    return await fn(params);
  }
}

///
/// await FunctionRegistry.invoke('readCharacteristic', {
//   'deviceId': '2037602C-1C15-BEE5-B4E7-8D6025F45DF1',
//   'serviceUuid': 'ef090000-11d6-42ba-93b8-9dd7ec090ab0',
//   'characteristicUuid': 'ef090001-11d6-42ba-93b8-9dd7ec090aa9',
//   'capabilities': ['read'],
// });