import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'networking.dart';
import 'location.dart';

// Get API key from environment variables
final String apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
final String openWeatherMapURL = dotenv.env['OPENWEATHER_BASE_URL'] ??
    "https://api.openweathermap.org/data/2.5/weather";

class WeatherModel {
  Position? currentPosition;

  LocationServices locationService = LocationServices();

  Future<dynamic> getCityWeather(String cityName) async {
    var _weatherData;

    if (kDebugMode) {
      print('Starting city weather request for: $cityName');
    }

    // Construct the URL with the city name
    var url = Uri.parse(
      '$openWeatherMapURL?q=$cityName&appid=$apiKey&units=metric',
    );

    if (kDebugMode) {
      print('API URL: $url');
      print('API Key: $apiKey');
      print('Making weather API request...');
    }

    // _weatherData = await NetworkHelper.getData(url);
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

    /// Call getData() AFTER location is obtained
    var url = Uri.parse(
      '$openWeatherMapURL?lat=${currentPosition!.latitude}&lon=${currentPosition!.longitude}&appid=$apiKey&units=metric',
    );

    if (kDebugMode) {
      print('API URL: $url');
      print('API Key: $apiKey');
      print('Making weather API request...');
    }

    // _weatherData = await NetworkHelper.getData(url);
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
