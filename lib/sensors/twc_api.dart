/// Developed by Alpenlogic LLC

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_watcher/models/weather_source.dart';

class TwcApi implements WeatherSource {
  final String apiKey;

  TwcApi({required this.apiKey});

  @override
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required bool isMetric,
  }) async {
    final units = isMetric ? 'm' : 'e'; // TWC uses 'm' for metric, 'e' for imperial
    final url = Uri.parse(
      'https://api.weather.com/v3/wx/observations/current?geocode=$latitude,$longitude&units=$units&language=en-US&format=json&apiKey=$apiKey',
    );

    // print('Fetching weather data from TWC: $url');

    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch weather data from TWC');
    }

    final json = jsonDecode(response.body);

    final temp = (json['temperature'] as num?)?.toDouble() ?? 0.0;
    final humidity = (json['relativeHumidity'] as num?)?.toDouble() ?? 0.0;
    final windSpeed = (json['windSpeed'] as num?)?.toDouble() ?? 0.0;
    final windDirection = (json['windDirection'] as num?)?.toDouble() ?? 0.0;
    final windGust = (json['windGust'] as num?)?.toDouble() ?? windSpeed;
    final icon = json['wx_icon']?.toString() ?? '';
    final unitLabel = isMetric ? '°C' : '°F';

    return WeatherData(
      temp: temp,
      humidity: humidity,
      unitLabel: unitLabel,
      windSpeed: windSpeed,
      windDirection: windDirection,
      windGust: windGust,
      icon: icon,
      source: 'theweathercompany',
    );
  }
}