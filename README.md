WeatherWatcher

WeatherWatcher is a Dart library developed by Alpenlogic LLC for gathering environmental weather data from various sources such as remote APIs, BLE devices, and local IoT sensors. It is designed to be modular, testable, and easy to integrate with Flutter apps.

Features
•	Modular weather data source interface (WeatherSource)
•	Remote API integration (OpenWeatherMap supported)
•	Unit preference handling (Celsius/Fahrenheit)
•	Weather update service with background lifecycle management
•	Easily extendable to support BLE or local sensor sources

Getting Started

Installation

Add this package to your pubspec.yaml:

dependencies:
weather_watcher:
path: ../weather_watcher  # Update this if hosted or published elsewhere

Import

import 'package:weather_watcher/weather_watcher.dart';

Usage

Instantiate the Updater

final weatherUpdater = WeatherUpdater(
apiKey: 'YOUR_OPENWEATHERMAP_API_KEY',
onWeatherUpdate: (WeatherData data) {
print('Temp: ${data.temp} ${data.unitLabel}, Humidity: ${data.humidity}%');
},
);

weatherUpdater.start();

WeatherData

Returned from any source, WeatherData contains:

class WeatherData {
final double temp;        // Already converted to the proper unit
final double humidity;    // % humidity
final String unitLabel;   // '°C' or '°F'
}

Extending

To add a new source, implement the abstract WeatherSource class:

abstract class WeatherSource {
Future<WeatherData> fetchWeather({
required double latitude,
required double longitude,
required bool isMetric,
});
}

Then plug it into the WeatherUpdater if desired.

License

Developed by Alpenlogic LLC. All rights reserved. For internal or commercial licensing, contact info@alpenlogic.com.