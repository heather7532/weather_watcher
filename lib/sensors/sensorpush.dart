import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:weather_watcher/models/sensor_data.dart';

import '../utils/ble_utils.dart';

/// Concrete class for SensorPush HT.w derived from SensorData
class SensorPush extends SensorData {
  SensorPush({
    required super.id,
    required super.name,
    required super.uri,
    required super.metadata,
  });

  static final FlutterReactiveBle _ble = FlutterReactiveBle();

  /// Default config for known SensorPush service and characteristics
  factory SensorPush.defaultConfig() {
    return SensorPush(
      id: 'ef090000-11d6-42ba-93b8-9dd7ec090ab0',
      name: 'SensorPush HT.w',
      uri: Uri.parse('https://www.sensorpush.com/bluetooth-api'),
      metadata: {
        'EF090001-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Device ID',
          'size': 4,
          'type': 'uint32',
          'permissions': 'read-only',
          'description': 'A unique numeric device ID for the sensor',
        },
        'EF090002-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Device Version',
          'size': 7,
          'type': 'uint8[7]',
          'permissions': 'read-only',
          'description': 'Model Identifier and version information',
        },
        'EF090003-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Tx Power',
          'size': 1,
          'type': 'uint8',
          'permissions': 'read/write',
          'description': 'Configures the device’s RF transmit power',
        },
        'EF090005-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Advertising Interval',
          'size': 1,
          'type': 'uint8',
          'permissions': 'read/write',
          'description': 'Sets the advertising interval of the device',
        },
        'EF090007-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Battery Voltage & Temp',
          'size': 4,
          'type': 'int16[2]',
          'permissions': 'read-only',
          'description': 'Battery voltage in mV and temperature at the time of reading',
        },
        'EF09000C-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'LED Control',
          'size': 1,
          'type': 'uint8',
          'permissions': 'read/write',
          'description': 'Controls the LED in the front of the device',
        },
        'EF09000D-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'MAC Address',
          'size': 6,
          'type': 'uint8[6]',
          'permissions': 'read-only',
          'description': 'The device’s Bluetooth MAC address',
        },
        'EF090080-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Read Temperature',
          'size': 4,
          'type': 'int32',
          'permissions': 'read/write',
          'description': 'To read data, write any 32-bit value to this characteristic to trigger a read. Once complete, the temperature in hundredths of °C will be available (e.g., 21.34°C reads as 2134). This also populates humidity.',
        },
        'EF090081-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Read Humidity',
          'size': 4,
          'type': 'int32',
          'permissions': 'read/write',
          'description': 'To read data, write any 32-bit value to this characteristic. Humidity in hundredths of %RH will be available (e.g., 21.34% reads as 2134). Also populates temperature.',
        },
        'EF090082-11D6-42BA-93B8-9DD7EC090AA9': {
          'data': 'Read Pressure',
          'size': 4,
          'type': 'int32',
          'permissions': 'read/write',
          'description': 'To read data, write any 32-bit value to this characteristic. Pressure in hundredths of Pa will be available (e.g., 9781364 = 97813.64 Pa)',
        },
      },
    );
  }

  static double parseTemperature(Uint8List data) {
    final raw = ByteData.sublistView(data).getInt32(0, Endian.little);
    return raw / 100.0;
  }

  static double parseHumidity(Uint8List data) {
    final raw = ByteData.sublistView(data).getUint32(0, Endian.little);
    return raw / 100.0;
  }

  static Map<String, dynamic> parseBatteryVoltage(Uint8List data) {
    final voltage = ByteData.sublistView(data).getUint16(0, Endian.little);
    final temperature = ByteData.sublistView(data).getUint16(2, Endian.little);
    return {
      'voltage_mV': voltage,
      'temperature_C': temperature,
    };
  }

  static String parseString(Uint8List data) => utf8.decode(data);

  /// Reads temperature and humidity from the sensor.
  Future<Map<String, dynamic>> getTempAndHumidity(
      {required String deviceId}) async {
    const triggerValue = [0x01, 0x00, 0x00, 0x00];
    final serviceUuid = Uuid.parse(id); // the SensorPush service UUID
    final tempCharUuid = Uuid.parse('EF090080-11D6-42BA-93B8-9DD7EC090AA9');
    final humidCharUuid = Uuid.parse('EF090081-11D6-42BA-93B8-9DD7EC090AA9');
    final presUuid = Uuid.parse('EF090082-11D6-42BA-93B8-9DD7EC090AA9');
    final voltageUuid = Uuid.parse('EF090007-11D6-42BA-93B8-9DD7EC090AA9');
    final returnValue = <String, dynamic>{};

    try {
      // Scan for devices with the specified name
      await BleUtils.scanForSupportedDevices(
        supportedNames: supportedSensorNames,
        scanDuration: const Duration(seconds: 2),
      );

      final connection = _ble.connectToDevice(id: deviceId);
      await for (final state in connection) {
        if (state.connectionState == DeviceConnectionState.connected) {
          if (kDebugMode) print('✅ Connected to $deviceId');

          // // Read temperature
          // if (kDebugMode) {
          //   print('Reading SensorPush characteristics...');
          // }
          // final tempBytes = await BleUtils.readCharacteristic(
          //   deviceId: deviceId,
          //   serviceUuid: serviceUuid,
          //   characteristicUuid: tempCharUuid,
          //   capabilities: ['read'],
          // );
          // returnValue['temperature_C'] = parseTemperature(Uint8List.fromList(tempBytes));

          // Read humidity
          final humidBytes = await BleUtils.readCharacteristic(
            deviceId: deviceId,
            serviceUuid: serviceUuid,
            characteristicUuid: humidCharUuid,
            capabilities: ['read'],
          );
          returnValue['humidity_percent'] =  parseHumidity(Uint8List.fromList(humidBytes));

          // Read battery voltage and temperature
          final voltageAndTemp = await BleUtils.readCharacteristic(
            deviceId: deviceId,
            serviceUuid: serviceUuid,
            characteristicUuid: voltageUuid,
            capabilities: ['read'],
          );

          final batteryData = parseBatteryVoltage(Uint8List.fromList(voltageAndTemp));
          returnValue['voltage_mV'] = batteryData['voltage_mV'];
          returnValue['temperature_C'] = batteryData['temperature_C'];


          return returnValue;
        } else if (state.connectionState == DeviceConnectionState.disconnected) {
          if (kDebugMode) print('❌ Disconnected from $deviceId');
          return {'error': 'Disconnected before read'};
        }
      }
    } catch (e) {
      print('❌ GATT connection error: $e');
      return {'error': e.toString()};
    }

    // ✅ Safety net return to satisfy Dart's non-nullable type checker
    return {'error': 'Unexpected exit without data'};
  }
}