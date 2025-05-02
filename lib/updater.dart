/// Developed by Alpenlogic LLC

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'models/weather_source.dart';
import 'sensors/open_weather_api.dart';
import 'package:geolocator/geolocator.dart';

class WeatherUpdater with WidgetsBindingObserver {
  Timer? _timer;
  late final Duration _fetchInterval;

  final void Function(WeatherData data) onWeatherUpdate;
  final String apiKey;
  final bool isMetric;

  final double? latitude;
  final double? longitude;

  /// Optional custom weather source for testing or alternative sensors.
  final WeatherSource _source;

  WeatherUpdater({
    required this.apiKey,
    required this.onWeatherUpdate,
    this.isMetric = false,
    this.latitude,
    this.longitude,
    Duration? fetchInterval,
    WeatherSource? customSource,
  })  : _source = customSource ?? OpenWeatherApi(apiKey: apiKey),
        _fetchInterval = fetchInterval ?? const Duration(minutes: 10); // ⏱️ updated to 10 min

  void start() {
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  void stop() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
  }

  /// Immediately fetches weather data, bypassing all interval checks.
  Future<void> fetchNow(isMetric) async {
    try {
      await _fetchAndUpdateWeather(isMetric);
    } catch (e, stack) {
      debugPrint('[WeatherUpdater] fetchNow error: $e\n$stack');
    }
  }

  void _startTimer() {
    _fetchAndUpdateWeather(isMetric); // initial fetch
    _timer = Timer.periodic(_fetchInterval, (timer) => _fetchAndUpdateWeather(isMetric));
  }

  Future<void> _fetchAndUpdateWeather(isMetric) async {
    try {
      double lat, lon;

      if (latitude != null && longitude != null) {
        lat = latitude!;
        lon = longitude!;
      } else {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        lat = position.latitude;
        lon = position.longitude;
      }

      print ('[WeatherUpdater] Fetching weather data for lat: $lat, lon: $lon, isMetric: $isMetric');
      final data = await _source.fetchWeather(
        latitude: lat,
        longitude: lon,
        isMetric: isMetric,
      );

      onWeatherUpdate(data);

      print('[WeatherUpdater] Temp: ${data.temp} ${data.unitLabel}, '
          'Humidity: ${data.humidity}%, '
          'Wind: ${data.windSpeed} @ ${data.windDirection}° (Gust: ${data.windGust})');
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