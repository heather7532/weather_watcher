/// Developed by Alpenlogic LLC

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'weather_source.dart';
import 'sources/remote_api_source.dart';
import 'package:geolocator/geolocator.dart';

class WeatherUpdater with WidgetsBindingObserver {
  Timer? _timer;
  Duration _fetchInterval = const Duration(minutes: 15);

  final void Function(WeatherData data) onWeatherUpdate;
  final String apiKey;
  final bool isMetric;

  /// Optional custom weather source for testing or alternative sources.
  final WeatherSource _source;

  WeatherUpdater({
    required this.apiKey,
    required this.onWeatherUpdate,
    this.isMetric = false,
    WeatherSource? customSource, // optional injection
  }) : _source = customSource ?? RemoteApiSource(apiKey: apiKey);

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  void _startTimer() {
    _fetchAndUpdateWeather(); // initial fetch
    _timer = Timer.periodic(_fetchInterval, (timer) => _fetchAndUpdateWeather());
  }

  Future<void> _fetchAndUpdateWeather() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final latitude = position.latitude;
      final longitude = position.longitude;

      final data = await _source.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        isMetric: isMetric,
      );

      onWeatherUpdate(data);
      print('[WeatherUpdater] Temp: ${data.temp} ${data.unitLabel}, '
          'Humidity: ${data.humidity}%, '
          'Wind: ${data.windSpeed} m/s @ ${data.windDirection}° (Gust: ${data.windGust} m/s)');
    } catch (e) {
      print('[WeatherUpdater] Error fetching weather data: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _timer?.cancel();
    } else if (state == AppLifecycleState.resumed) {
      _startTimer();
    }
  }
}