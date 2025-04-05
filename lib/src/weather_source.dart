/// Developed by Alpenlogic LLC

abstract class WeatherSource {
  /// Fetch weather data given a latitude and longitude.
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required bool isMetric,
  });
}

class WeatherData {
  final double temp;        // Already in the correct unit scale
  final double humidity;
  final String unitLabel;   // '°C' or '°F'

  WeatherData({
    required this.temp,
    required this.humidity,
    required this.unitLabel,
  });
}