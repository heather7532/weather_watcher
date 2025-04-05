/// Developed by Alpenlogic LLC

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_watcher/src/weather_source.dart';

class RemoteApiSource implements WeatherSource {
  final String apiKey;

  RemoteApiSource({required this.apiKey});

  @override
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required bool isMetric,
  }) async {
    final units = 'metric'; // Always request metric (Celsius)
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$units&appid=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data');
    }

    final json = jsonDecode(response.body);
    final tempC = (json['main']['temp'] as num).toDouble();
    final humidity = (json['main']['humidity'] as num).toDouble();

    final temp = isMetric ? tempC : (tempC * 9 / 5) + 32;
    final unitLabel = isMetric ? '°C' : '°F';

    return WeatherData(
      temp: temp,
      humidity: humidity,
      unitLabel: unitLabel,
    );
  }
}
