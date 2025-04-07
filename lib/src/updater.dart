/// Developed by Alpenlogic LLC

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'weather_source.dart';
import 'sources/remote_api_source.dart';
import 'package:geolocator/geolocator.dart';

class WeatherUpdater with WidgetsBindingObserver {
  Timer? _timer;
  late final Duration _fetchInterval;

  final void Function(WeatherData data) onWeatherUpdate;
  final String apiKey;
  final bool isMetric;

  final double? latitude;
  final double? longitude;

  /// Optional custom weather source for testing or alternative sources.
  final WeatherSource _source;

  WeatherUpdater({
    required this.apiKey,
    required this.onWeatherUpdate,
    this.isMetric = false,
    this.latitude,
    this.longitude,
    Duration? fetchInterval,
    WeatherSource? customSource,
  })  : _source = customSource ?? RemoteApiSource(apiKey: apiKey),
        _fetchInterval = fetchInterval ?? const Duration(minutes: 10); // ⏱️ updated to 10 min

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