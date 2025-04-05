/// Developed by Alpenlogic LLC

import 'dart:async';
import 'package:flutter/widgets.dart';
import 'weather_source.dart';
import 'sources/remote_api_source.dart';

class WeatherUpdater with WidgetsBindingObserver {
  Timer? _timer;
  Duration _fetchInterval = const Duration(minutes: 15);

  /// Callback that is invoked when new weather data is fetched.
  final void Function(WeatherData data) onWeatherUpdate;

  /// API key used for the remote weather service.
  final String apiKey;

  WeatherUpdater({
    required this.apiKey,
    required this.onWeatherUpdate,
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
      // Replace these with real geolocation calls
      final double latitude = 40.07011;
      final double longitude = -105.893;

      final source = RemoteApiSource(apiKey: apiKey);
      final data = await source.fetchWeather(
        latitude: latitude,
        longitude: longitude,
        isMetric: false,
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
