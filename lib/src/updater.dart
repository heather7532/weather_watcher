/// Developed by Alpenlogic LLC

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'weather_source.dart';
import 'sources/remote_api_source.dart';
import 'package:geolocator/geolocator.dart';

class WeatherUpdater with WidgetsBindingObserver {
  Timer? _timer;
  Duration _fetchInterval = const Duration(minutes: 15);

  /// Callback that is invoked when new weather data is fetched.
  final void Function(WeatherData data) onWeatherUpdate;

  /// API key used for the remote weather service.
  final String apiKey;

  /// Unit system preference (true for metric, false for imperial).
  final bool isMetric;

  WeatherUpdater({
    required this.apiKey,
    required this.onWeatherUpdate,
    this.isMetric = false,
  });

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

      final source = RemoteApiSource(apiKey: apiKey);
      final data = await source.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        isMetric: isMetric,
      );

      onWeatherUpdate(data);
      print('[WeatherUpdater] Temp: ${data.temp} ${data.unitLabel}, Humidity: ${data.humidity}%');
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