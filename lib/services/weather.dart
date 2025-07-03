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

  /// Get detailed weather data including current, forecast, and astronomy
  Future<Map<String, dynamic>> getDetailedWeatherData({
    double? lat,
    double? lon,
    String? cityName,
  }) async {
    try {
      late double latitude, longitude;

      if (lat != null && lon != null) {
        latitude = lat;
        longitude = lon;
      } else if (cityName != null && cityName.isNotEmpty) {
        // Get coordinates from city name using geocoding
        var geocodeData = await _getCoordinatesFromCity(cityName);
        latitude = geocodeData['lat'];
        longitude = geocodeData['lon'];
      } else {
        // Use current location
        currentPosition = await locationService.getCurrentLocation();
        latitude = currentPosition!.latitude;
        longitude = currentPosition!.longitude;
      }

      // Fetch all weather data concurrently
      final futures = await Future.wait([
        _getCurrentWeather(latitude, longitude),
        _getForecastWeather(latitude, longitude),
        _getAstronomyData(latitude, longitude),
      ]);

      return {
        'current': futures[0],
        'forecast': futures[1],
        'astronomy': futures[2],
        'coordinates': {'lat': latitude, 'lon': longitude},
      };
    } catch (e) {
      if (kDebugMode) {
        print('Error getting detailed weather data: $e');
      }
      rethrow;
    }
  }

  /// Get coordinates from city name
  Future<Map<String, dynamic>> _getCoordinatesFromCity(String cityName) async {
    var url = Uri.parse(
      'https://api.openweathermap.org/geo/1.0/direct?q=$cityName&limit=1&appid=${Environment.apiKey}',
    );

    var networkHelper = NetworkHelper(url.toString());
    var data = await networkHelper.getData();

    if (data != null && data.isNotEmpty) {
      return {
        'lat': data[0]['lat'],
        'lon': data[0]['lon'],
        'name': data[0]['name'],
        'country': data[0]['country'],
      };
    } else {
      throw Exception('City not found: $cityName');
    }
  }

  /// Get current weather data
  Future<dynamic> _getCurrentWeather(double lat, double lon) async {
    var url = Uri.parse(
      '${Environment.baseUrl}?lat=$lat&lon=$lon&appid=${Environment.apiKey}&units=metric',
    );

    var networkHelper = NetworkHelper(url.toString());
    return await networkHelper.getData();
  }

  /// Get 5-day forecast data
  Future<dynamic> _getForecastWeather(double lat, double lon) async {
    var url = Uri.parse(
      'https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=${Environment.apiKey}&units=metric',
    );

    var networkHelper = NetworkHelper(url.toString());
    return await networkHelper.getData();
  }

  /// Get astronomy data (sunrise, sunset, moon phase)
  Future<Map<String, dynamic>> _getAstronomyData(double lat, double lon) async {
    // Using the current weather data which includes sunrise/sunset
    var currentWeather = await _getCurrentWeather(lat, lon);

    return {
      'sunrise': currentWeather['sys']['sunrise'],
      'sunset': currentWeather['sys']['sunset'],
      'timezone': currentWeather['timezone'],
      // Moon phase calculation (simplified)
      'moonPhase': _calculateMoonPhase(),
    };
  }

  /// Calculate current moon phase
  String _calculateMoonPhase() {
    final now = DateTime.now();
    final year = now.year;
    final month = now.month;
    final day = now.day;

    // Simplified moon phase calculation
    final totalDays = (year - 2000) * 365.25 + (month - 1) * 30.44 + day;
    final moonCycle = totalDays % 29.53;

    if (moonCycle < 1.84566) return '🌑'; // New Moon
    if (moonCycle < 5.53699) return '🌒'; // Waxing Crescent
    if (moonCycle < 9.22831) return '🌓'; // First Quarter
    if (moonCycle < 12.91963) return '🌔'; // Waxing Gibbous
    if (moonCycle < 16.61096) return '🌕'; // Full Moon
    if (moonCycle < 20.30228) return '🌖'; // Waning Gibbous
    if (moonCycle < 23.99361) return '🌗'; // Last Quarter
    if (moonCycle < 27.68493) return '🌘'; // Waning Crescent
    return '🌑'; // New Moon
  }

  // Legacy methods for backward compatibility
  Future<dynamic> getCityWeather(String cityName) async {
    try {
      var detailedData = await getDetailedWeatherData(cityName: cityName);
      return detailedData['current'];
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> getLocationWeather() async {
    try {
      var detailedData = await getDetailedWeatherData();
      return detailedData['current'];
    } catch (e) {
      rethrow;
    }
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
