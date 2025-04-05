import 'package:weather_watcher/weather_watcher.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WeatherData Tests', () {
    test('Converts Celsius to Fahrenheit correctly', () {
      // Create a WeatherData instance with a known Celsius temperature.
      final weather = WeatherData(tempCelsius: 25.0, humidity: 60.0);

      // Fahrenheit calculation: (25 * 9/5) + 32 = 77.0
      expect(weather.tempFahrenheit, closeTo(77.0, 0.01));

      // Using getTemp with metric = true should return the Celsius value.
      expect(weather.getTemp(isMetric: true), equals(25.0));

      // Using getTemp with metric = false should return the Fahrenheit value.
      expect(weather.getTemp(isMetric: false), closeTo(77.0, 0.01));
    });
  });
}