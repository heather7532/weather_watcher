import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_watcher/updater.dart';
import 'package:weather_watcher/models/weather_source.dart';

const MethodChannel geolocatorChannel = MethodChannel('flutter.baseflow.com/geolocator');

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
      windSpeed: isMetric ? 5.0 : 11.2,
      windDirection: 225.0,
      windGust: isMetric ? 7.5 : 16.7,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    geolocatorChannel.setMockMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'getCurrentPosition') {
        return {
          'latitude': 40.07011,
          'longitude': -105.893,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
          'accuracy': 1.0,
          'altitude': 1600.0,
          'heading': 0.0,
          'speed': 0.0,
          'speed_accuracy': 0.0,
        };
      }
      return null;
    });
  });

  tearDown(() {
    geolocatorChannel.setMockMethodCallHandler(null);
  });

  test('WeatherUpdater fetches and updates mock weather data', () async {
    final weatherUpdater = WeatherUpdater(
      apiKey: 'mock-api-key',
      isMetric: true,
      customSource: MockWeatherSource(),
      onWeatherUpdate: (WeatherData data) {
        expect(data.temp, 20.0);
        expect(data.humidity, 50.0);
        expect(data.unitLabel, '°C');
        expect(data.windSpeed, 5.0);
        expect(data.windDirection, 225.0);
        expect(data.windGust, 7.5);
      },
    );

    weatherUpdater.start();
    await Future.delayed(const Duration(seconds: 1));
    weatherUpdater.stop();
  });
}