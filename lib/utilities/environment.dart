import 'package:flutter/foundation.dart';

/// Environment configuration class that handles API keys
/// across different platforms (mobile, desktop, web)
class Environment {
  /// Gets the OpenWeatherMap API key based on platform
  static String get apiKey {
    if (kIsWeb) {
      // For web deployment, use compile-time constant
      // You can set this during build: flutter build web --dart-define=API_KEY=your_key
      return const String.fromEnvironment(
        'API_KEY',
        defaultValue: '4ab244dbb64533a71879e35e8017c667', // Your actual API key for web
      );
    } else {
      // For mobile/desktop, this will be loaded from .env file
      // This is set in weather.dart using flutter_dotenv
      return _mobileApiKey ?? '4ab244dbb64533a71879e35e8017c667';
    }
  }

  /// Gets the OpenWeatherMap base URL
  static String get baseUrl {
    if (kIsWeb) {
      return const String.fromEnvironment(
        'BASE_URL',
        defaultValue: 'https://api.openweathermap.org/data/2.5/weather',
      );
    } else {
      return _mobileBaseUrl ?? 'https://api.openweathermap.org/data/2.5/weather';
    }
  }

  // These will be set by weather.dart for mobile platforms
  static String? _mobileApiKey;
  static String? _mobileBaseUrl;

  /// Sets mobile-specific environment variables (called from weather.dart)
  static void setMobileConfig({required String apiKey, required String baseUrl}) {
    _mobileApiKey = apiKey;
    _mobileBaseUrl = baseUrl;
  }

  /// Validates that API key is available
  static bool get isConfigured {
    return apiKey.isNotEmpty && apiKey != 'your_api_key_here';
  }
}
