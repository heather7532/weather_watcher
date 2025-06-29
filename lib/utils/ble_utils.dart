// lib/utils/ble_utils.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;
import 'package:weather_watcher/models/ble_characteristic.dart';
import 'gatt_constants.dart';

/// List of supported BLE sensor name substrings
const List<String> supportedSensorNames = [
  'sensorpush ht.w',
];

class BleUtils {
  static final FlutterReactiveBle _ble = FlutterReactiveBle();
  static final StreamController<List<DiscoveredDevice>> _deviceController =
      StreamController<List<DiscoveredDevice>>.broadcast();
  static final Map<String, DiscoveredDevice> _deviceMap = {};
  static StreamSubscription<DiscoveredDevice>? _scanSubscription;
  static StreamSubscription<ConnectionStateUpdate>? _connection;
  static Duration scanDuration = const Duration(milliseconds: 500);

  static Stream<List<DiscoveredDevice>> get devicesStream =>
      _deviceController.stream;

  final location = loc.Location();


  Future<void> ensurePermissions() async {
    bool serviceEnabled;
    loc.PermissionStatus permissionStatus;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Location services are not enabled, exit.  Request user permission
        // to enable location services.
        debugPrint("❌ Location services are not enabled.");
        return;
      }
    } else {
      // Location services are enabled, check permissions.
      permissionStatus = await location.hasPermission();
      if (permissionStatus == loc.PermissionStatus.denied) {
        permissionStatus = await location.requestPermission();
        if (permissionStatus != loc.PermissionStatus.granted) {
          // Permission not granted, exit.
          debugPrint("❌ Location permission not granted.");
          return;
        }
      } else if (permissionStatus == loc.PermissionStatus.deniedForever) {
        // Permission denied forever, show a message to the user.
        debugPrint("❌ Location permission denied forever.");
        openAppSettings();
        if (permissionStatus != loc.PermissionStatus.granted) {
          // Location services are still not enabled, exit.
          return;
        }
      }
    }
  }

  static Future<List<DiscoveredDevice>> scanForSupportedSensors({
    required List<String> supportedNames,
    Duration scanDuration = const Duration(milliseconds: 2500),
  }) async {
    final completer = Completer<List<DiscoveredDevice>>();
    final Map<String, DiscoveredDevice> matches = {};
    final Set<String> nameFilters = supportedNames.map((s) => s.toLowerCase()).toSet();

    late final StreamSubscription<DiscoveredDevice> sub;

    debugPrint('🔍 Starting BLE scanForSupportedSensors with names: $nameFilters');

    try {
      sub = _ble.scanForDevices(
        withServices: [],
        scanMode: ScanMode.lowLatency,
      ).listen((device) {
        final name = device.name.toLowerCase();
        if (nameFilters.any((filter) => name.contains(filter))) {
          if (!matches.containsKey(device.id)) {
            matches[device.id] = device;
            debugPrint('✅ Matched: ${device.name} [${device.id}] RSSI: ${device.rssi}');
          }
        }
      });

      await Future.delayed(scanDuration);
    } catch (e) {
      debugPrint('❌ Scan error: $e');
    } finally {
      await sub.cancel();
      return matches.values.toList();
    }
  }

  static Future<void> startBleScan() async {
    // ⛳ Step 1: Permission check
    final loc.Location location = loc.Location();

    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        throw Exception("Location services must be enabled for BLE scanning.");
      }
    }

    loc.PermissionStatus permission = await location.hasPermission();
    if (permission == loc.PermissionStatus.denied) {
      permission = await location.requestPermission();
    }

// 🕒 Recheck after delay (iOS workaround)
    await Future.delayed(const Duration(seconds: 2));
    permission = await location.hasPermission();

    if (permission != loc.PermissionStatus.granted) {
      if (permission == loc.PermissionStatus.deniedForever) {
        openAppSettings();
      }
      throw Exception("Location permission is required for BLE scanning.");
    }

    // 🧠 Step 2: Wait until BLE is powered on
    final bleStatus =
        await _ble.statusStream.firstWhere((s) => s == BleStatus.ready);
    debugPrint("✅ BLE is ready: $bleStatus");

    // 🧼 Step 3: Clean previous data
    _deviceMap.clear();
    _scanSubscription?.cancel();

    // 🚀 Step 4: Start scanning
    _scanSubscription = _ble.scanForDevices(
      withServices: [],
      scanMode: ScanMode.lowLatency,
    ).listen((device) {
      _deviceMap[device.id] = device;
      _deviceController.add(_deviceMap.values.toList());
    },
        onError: (err) => {
              debugPrint("❌ Scan error: $err"),
            });
  }

  static void stopBleScan() {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    debugPrint("🛑 Scan stopped.");
  }

  static void dispose() {
    stopBleScan();
    _deviceController.close();
    _connection?.cancel();
  }

  static Future<List<DiscoveredService>> discoverServices(
      String deviceId) async {
    return await _ble.discoverServices(deviceId);
  }

  static Future<void> connectToDevice(String deviceId) async {
    _connection?.cancel(); // cancel previous connection if any

    final completer = Completer<void>();

    _connection = _ble
        .connectToDevice(
      id: deviceId,
      connectionTimeout: const Duration(milliseconds: 500),
    )
        .listen((update) {
      debugPrint("🔗 Connection state: ${update.connectionState}");
      if (update.connectionState == DeviceConnectionState.connected) {
        completer.complete();
      } else if (update.connectionState == DeviceConnectionState.disconnected) {
        if (!completer.isCompleted) {
          completer.completeError("Disconnected before fully connecting");
        }
      }
    }, onError: (err) {
      if (!completer.isCompleted) {
        debugPrint("❌ Connection error: $err");
        completer.completeError(err);
      }
    });

    return completer.future;
  }

  static Future<List<int>> readCharacteristic({
    required String deviceId,
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
    required List<String> capabilities,
  }) async {
    if (!capabilities.contains('read')) {
      debugPrint("⚠️ Characteristic $characteristicUuid is not readable.");
      return Future.error("Characteristic is not readable.");
    }

    final qualifiedChar = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    try {
      debugPrint("📄 Attempting read from characteristic: "
            "deviceId=$deviceId, "
            "serviceUuid=$serviceUuid, "
            "characteristicUuid=$characteristicUuid, "
            "capabilities=$capabilities");
      final result = await _ble.readCharacteristic(qualifiedChar);
      debugPrint("✅ Read success for $characteristicUuid: $result");
      return result;
      // remove retry logic
    } catch (e) {
      debugPrint("❌ Read failed for $characteristicUuid: $e");
      return Future.error("Read failed: $e");
    }
  }

  static Future<void> writeCharacteristic({
    required String deviceId,
    required Uuid serviceUuid,
    required Uuid characteristicUuid,
    required List<int> value,
  }) async {
    final qualifiedChar = QualifiedCharacteristic(
      serviceId: serviceUuid,
      characteristicId: characteristicUuid,
      deviceId: deviceId,
    );

    try {
      await _ble.writeCharacteristicWithResponse(qualifiedChar, value: value);
      debugPrint("✅ Write success to $characteristicUuid: $value");
    } catch (e) {
      debugPrint("❌ Write failed for $characteristicUuid: $e");
      rethrow;
    }
  }

  static Future<void> disconnect() async {
    await _connection?.cancel();
    _connection = null;
    debugPrint("🔌 Disconnected from device");
  }

  // Connect to a device and check its GATT services and characteristics
  // This function is mostly used for debugging purposes
  static Future<Map<String, List<BleCharacteristic>>> connectAndCheckGatt(
      String deviceId) async {
    final result = <String, List<BleCharacteristic>>{};
    debugPrint('🔌 Attempting connection to $deviceId');

    try {
      final connection = _ble.connectToDevice(id: deviceId);
      await for (final state in connection) {
        if (state.connectionState == DeviceConnectionState.connected) {
          debugPrint('✅ Connected to $deviceId');

          final services = await _ble.discoverServices(deviceId);
          for (final service in services) {
            final serviceName = GattServices
                    .names[service.serviceId.toString().toLowerCase()] ??
                service.serviceId.toString();

            final characteristics = <BleCharacteristic>[];
            for (final char in service.characteristics) {
              final uuid = char.characteristicId.toString();
              final name =
                  GattCharacteristics.names[uuid.toLowerCase()] ?? uuid;

              final capabilities = <String>[
                if (char.isReadable) 'read',
                if (char.isWritableWithResponse ||
                    char.isWritableWithoutResponse)
                  'write',
                if (char.isNotifiable) 'notify',
              ];

              characteristics.add(BleCharacteristic(
                uuid: uuid,
                name: name,
                capabilities: capabilities,
              ));
            }
            result[serviceName] = characteristics;
          }
          break;
        }
      }
    } catch (e) {
      debugPrint('❌ GATT connection error: $e');
      rethrow;
    }

    return result;
  }
}
