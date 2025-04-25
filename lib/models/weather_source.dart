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
  final double temp;            // Temperature in proper unit (C or F)
  final double humidity;        // %
  final String unitLabel;       // '°C' or '°F'

  final double windSpeed;       // Wind speed in appropriate unit (m/s or mph)
  final double windDirection;   // Wind direction in degrees
  final double windGust;       // Optional wind gust in same unit as speed

  WeatherData({
    required this.temp,
    required this.humidity,
    required this.unitLabel,
    required this.windSpeed,
    required this.windDirection,
    required this.windGust,
  });
}