// lib/utils/gatt_constants.dart

class GattServices {
  static const String GENERIC_ACCESS = "1800";
  static const String GENERIC_ATTRIBUTE = "1801";
  static const String DEVICE_INFORMATION = "180A";
  static const String BATTERY_SERVICE = "180F";
  static const String ENVIRONMENTAL_SENSING = "181A";
  static const String HEALTH_THERMOMETER = "1809";
  static const String HEART_RATE = "180D";

  static const Map<String, String> names = {
    GENERIC_ACCESS: "Generic Access",
    GENERIC_ATTRIBUTE: "Generic Attribute",
    DEVICE_INFORMATION: "Device Information",
    BATTERY_SERVICE: "Battery Service",
    ENVIRONMENTAL_SENSING: "Environmental Sensing",
    HEALTH_THERMOMETER: "Health Thermometer",
    HEART_RATE: "Heart Rate",
  };
}

class GattCharacteristics {
  static const String TEMPERATURE = "2A6E";
  static const String HUMIDITY = "2A6F";
  static const String PRESSURE = "2A6D";
  static const String BATTERY_LEVEL = "2A19";
  static const String MANUFACTURER_NAME = "2A29";
  static const String MODEL_NUMBER = "2A24";
  static const String TEMPERATURE_MEASUREMENT = "2A1C";

  static const Map<String, String> names = {
    TEMPERATURE: "Temperature",
    HUMIDITY: "Humidity",
    PRESSURE: "Pressure",
    BATTERY_LEVEL: "Battery Level",
    MANUFACTURER_NAME: "Manufacturer Name",
    MODEL_NUMBER: "Model Number",
    TEMPERATURE_MEASUREMENT: "Temperature Measurement",
  };
}