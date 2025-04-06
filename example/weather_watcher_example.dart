import 'package:weather_watcher/weather_watcher.dart';

void main() async {
  final weatherUpdater = WeatherUpdater(
    apiKey: 'YOUR_API_KEY_HERE', // Replace with your actual OpenWeatherMap API key
    onWeatherUpdate: (WeatherData data) {
      print('Temperature: ${data.temp} ${data.unitLabel}');
      print('Humidity: ${data.humidity}%');
    },
  );

// Start periodic weather updates
  weatherUpdater.start();

// Let it run for one cycle for this example
  await Future.delayed(Duration(seconds: 20));

// Stop updater to clean up
  weatherUpdater.stop();
}