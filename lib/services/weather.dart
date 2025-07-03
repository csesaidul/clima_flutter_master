import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'networking.dart';
import 'location.dart';
import '../utilities/environment.dart';

class WeatherModel {
  Position? currentPosition;

  LocationServices locationService = LocationServices();

  // Initialize environment configuration
  WeatherModel() {
    _initializeConfig();
  }

  void _initializeConfig() {
    if (!kIsWeb) {
      // For mobile/desktop, get values from .env file
      final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '4ab244dbb64533a71879e35e8017c667';
      final baseUrl = dotenv.env['OPENWEATHER_BASE_URL'] ??
          'https://api.openweathermap.org/data/2.5/weather';

      Environment.setMobileConfig(apiKey: apiKey, baseUrl: baseUrl);
    }
    // For web, Environment class will use compile-time constants
  }

  Future<dynamic> getCityWeather(String cityName) async {
    var _weatherData;

    if (kDebugMode) {
      print('Starting city weather request for: $cityName');
    }

    // Construct the URL with the city name using Environment class
    var url = Uri.parse(
      '${Environment.baseUrl}?q=$cityName&appid=${Environment.apiKey}&units=metric',
    );

    if (kDebugMode) {
      print('API URL: $url');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
      print('Making weather API request...');
    }

    var networkHelper = NetworkHelper(url.toString());
    _weatherData = await networkHelper.getData();

    if (kDebugMode) {
      print('Weather data received successfully: $_weatherData');
      // Print specific weather details if available
      if (_weatherData != null) {
        print('City: ${_weatherData['name'] ?? 'Unknown'}');
        print('Temperature: ${_weatherData['main']?['temp'] ?? 'Unknown'}°C');
        print('Weather: ${_weatherData['weather']?[0]?['main'] ?? 'Unknown'}');
        print(
          'Description: ${_weatherData['weather']?[0]?['description'] ?? 'Unknown'}',
        );
      }
    }

    return _weatherData;
  }

  Future<dynamic> getLocationWeather() async {
    var _weatherData;

    if (kDebugMode) {
      print('Starting location request...');
    }

    // Request current location
    currentPosition = await locationService.getCurrentLocation();

    if (kDebugMode) {
      print(
        'Location obtained: Lat=${currentPosition!.latitude}, Lon=${currentPosition!.longitude}',
      );
    }

    /// Call getData() AFTER location is obtained using Environment class
    var url = Uri.parse(
      '${Environment.baseUrl}?lat=${currentPosition!.latitude}&lon=${currentPosition!.longitude}&appid=${Environment.apiKey}&units=metric',
    );

    if (kDebugMode) {
      print('API URL: $url');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
      print('Making weather API request...');
    }

    var networkHelper = NetworkHelper(url.toString());
    _weatherData = await networkHelper.getData();

    if (kDebugMode) {
      print('Weather data received successfully: $_weatherData');
      // Print specific weather details if available
      if (_weatherData != null) {
        print('City: ${_weatherData['name'] ?? 'Unknown'}');
        print('Temperature: ${_weatherData['main']?['temp'] ?? 'Unknown'}°C');
        print('Weather: ${_weatherData['weather']?[0]?['main'] ?? 'Unknown'}');
        print(
          'Description: ${_weatherData['weather']?[0]?['description'] ?? 'Unknown'}',
        );
      }
    }

    return _weatherData;
  }

  String getWeatherIcon(int condition) {
    if (condition < 300) {
      return '🌩';
    } else if (condition < 400) {
      return '🌧';
    } else if (condition < 600) {
      return '☔️';
    } else if (condition < 700) {
      return '☃️';
    } else if (condition < 800) {
      return '🌫';
    } else if (condition == 800) {
      return '☀️';
    } else if (condition <= 804) {
      return '☁️';
    } else {
      return '🤷‍';
    }
  }

  String getMessage(int temp) {
    if (temp > 25) {
      return 'It\'s 🍦 time';
    } else if (temp > 20) {
      return 'Time for shorts and 👕';
    } else if (temp < 10) {
      return 'You\'ll need 🧣 and 🧤';
    } else {
      return 'Bring a 🧥 just in case';
    }
  }
}
