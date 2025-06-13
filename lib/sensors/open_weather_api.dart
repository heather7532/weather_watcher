/// Developed by Alpenlogic LLC

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:weather_watcher/models/weather_source.dart';

class OpenWeatherApi implements WeatherSource {
  final String apiKey;

  OpenWeatherApi({required this.apiKey});

  @override
  Future<WeatherData> fetchWeather({
    required double latitude,
    required double longitude,
    required bool isMetric,
  }) async {
    final units = isMetric ? 'metric' : 'imperial';
    final url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&units=$units&appid=$apiKey',
    );

    final response = await http.get(url);
    if (response.statusCode != 200) {
      debugPrint('🔍 OpenWeather response: ${response.statusCode} ${response.body}');
      throw Exception('Failed to fetch weather data: ${response.statusCode} ${response.body}');
    }

    final json = jsonDecode(response.body);

    final temp = (json['main']['temp'] as num).toDouble();
    final humidity = (json['main']['humidity'] as num).toDouble();
    final windSpeed = (json['wind']['speed'] as num?)?.toDouble() ?? 0.0;
    final windDirection = (json['wind']['deg'] as num?)?.toDouble() ?? 0.0;
    final windGust = (json['wind']['gust'] as num?)?.toDouble() ?? windSpeed;
    final icon = (json['weather'] as List?)?.first?['icon'] as String? ?? 'unknown';
    final source = "openweather";
    final unitLabel = isMetric ? '°C' : '°F';

    return WeatherData(
      temp: temp,
      humidity: humidity,
      unitLabel: unitLabel,
      windSpeed: windSpeed,
      windDirection: windDirection,
      windGust: windGust,
      icon: icon,
      source: source,
    );
  }
}