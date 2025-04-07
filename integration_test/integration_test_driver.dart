import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:weather_watcher/weather_watcher.dart';

import '../test/secrets_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Live weather API test', (tester) async {
    final weatherUpdater = WeatherUpdater(
      apiKey: TestSecrets.openWeatherApiKey,
      isMetric: true,
      onWeatherUpdate: (data) {
        print('✅ Temperature: ${data.temp} ${data.unitLabel}');
        print('✅ Humidity: ${data.humidity}%');
        print('✅ Wind: ${data.windSpeed} m/s, Gust: ${data.windGust}, Dir: ${data.windDirection}°');

        expect(data.temp, greaterThan(-50)); // crude sanity check
        expect(data.humidity, greaterThanOrEqualTo(0));
        expect(data.windSpeed, greaterThanOrEqualTo(0));
      },
    );

    weatherUpdater.start();
    await Future.delayed(Duration(seconds: 5));
    weatherUpdater.stop();
  });
}