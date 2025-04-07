import 'package:weather_watcher/weather_watcher.dart';

void main() async {
  final weatherUpdater = WeatherUpdater(
    apiKey: 'YOUR_API_KEY_HERE', // Replace with your actual OpenWeatherMap API key
    isMetric: true, // Change to false if you prefer imperial units
    onWeatherUpdate: (WeatherData data) {
      print('Temperature: ${data.temp} ${data.unitLabel}');
      print('Humidity: ${data.humidity}%');
      print('Wind Speed: ${data.windSpeed} ${data.unitLabel == '°C' ? 'm/s' : 'mph'}');
      print('Wind Direction: ${data.windDirection}°');
      print('Wind Gust: ${data.windGust?.toStringAsFixed(1) ?? 'N/A'}');
    },
  );

  // Start periodic weather updates
  weatherUpdater.start();

  // Let it run for one cycle for this example
  await Future.delayed(Duration(seconds: 20));

  // Stop updater to clean up
  weatherUpdater.stop();
}