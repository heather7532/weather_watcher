import 'package:flutter_test/flutter_test.dart';
import 'package:weather_watcher/src/updater.dart';
import 'package:weather_watcher/src/weather_source.dart';

class MockWeatherSource implements WeatherSource {
  @override
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required bool isMetric,
  }) async {
    return WeatherData(
      temp: isMetric ? 20.0 : 68.0,
      humidity: 50.0,
      unitLabel: isMetric ? '°C' : '°F',
    );
  }
}

void main() {
  test('WeatherUpdater fetches and updates weather data', () async {
    final mockSource = MockWeatherSource();
    final weatherUpdater = WeatherUpdater(
      apiKey: 'test_api_key',
      onWeatherUpdate: (WeatherData data) {
        expect(data.temp, 20.0);
        expect(data.humidity, 50.0);
        expect(data.unitLabel, '°C');
      },
    );

    weatherUpdater.start();
    await Future.delayed(Duration(seconds: 1));
    weatherUpdater.stop();
  });
}