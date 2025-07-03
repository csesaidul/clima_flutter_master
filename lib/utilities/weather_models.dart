/// Weather data models for detailed weather information
class WeatherData {
  final CurrentWeather current;
  final List<DailyForecast> dailyForecast;
  final List<HourlyForecast> hourlyForecast;
  final AstronomyData astronomy;

  WeatherData({
    required this.current,
    required this.dailyForecast,
    required this.hourlyForecast,
    required this.astronomy,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    return WeatherData(
      current: CurrentWeather.fromJson(json['current']),
      dailyForecast: DailyForecast.listFromJson(json['forecast']),
      hourlyForecast: HourlyForecast.listFromJson(json['forecast']),
      astronomy: AstronomyData.fromJson(json['astronomy']),
    );
  }
}

/// Current weather information
class CurrentWeather {
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double pressure;
  final double windSpeed;
  final int windDirection;
  final double visibility;
  final int uvIndex;
  final String description;
  final String icon;
  final String cityName;
  final String country;

  CurrentWeather({
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.pressure,
    required this.windSpeed,
    required this.windDirection,
    required this.visibility,
    required this.uvIndex,
    required this.description,
    required this.icon,
    required this.cityName,
    required this.country,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(),
      humidity: json['main']['humidity'] ?? 0,
      pressure: (json['main']['pressure'] ?? 0.0).toDouble(),
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
      windDirection: json['wind']?['deg'] ?? 0,
      visibility: (json['visibility'] ?? 0.0).toDouble() / 1000, // Convert to km
      uvIndex: 0, // Not available in current API, would need separate call
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      cityName: json['name'] ?? 'Unknown',
      country: json['sys']['country'] ?? '',
    );
  }

  String get windDirectionText {
    if (windDirection >= 348.75 || windDirection < 11.25) return 'N';
    if (windDirection < 33.75) return 'NNE';
    if (windDirection < 56.25) return 'NE';
    if (windDirection < 78.75) return 'ENE';
    if (windDirection < 101.25) return 'E';
    if (windDirection < 123.75) return 'ESE';
    if (windDirection < 146.25) return 'SE';
    if (windDirection < 168.75) return 'SSE';
    if (windDirection < 191.25) return 'S';
    if (windDirection < 213.75) return 'SSW';
    if (windDirection < 236.25) return 'SW';
    if (windDirection < 258.75) return 'WSW';
    if (windDirection < 281.25) return 'W';
    if (windDirection < 303.75) return 'WNW';
    if (windDirection < 326.25) return 'NW';
    if (windDirection < 348.75) return 'NNW';
    return 'N';
  }
}

/// Daily forecast data
class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final int precipitationChance;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    required this.precipitationChance,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      maxTemp: (json['main']['temp_max'] ?? 0.0).toDouble(),
      minTemp: (json['main']['temp_min'] ?? 0.0).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
      precipitationChance: ((json['pop'] ?? 0.0) * 100).round(),
    );
  }

  static List<DailyForecast> listFromJson(Map<String, dynamic> forecastJson) {
    List<dynamic> list = forecastJson['list'] ?? [];
    Map<String, DailyForecast> dailyMap = {};

    for (var item in list) {
      var forecast = DailyForecast.fromJson(item);
      String dateKey = forecast.date.toIso8601String().split('T')[0];

      if (!dailyMap.containsKey(dateKey)) {
        dailyMap[dateKey] = forecast;
      } else {
        // Update with higher max temp and lower min temp
        var existing = dailyMap[dateKey]!;
        dailyMap[dateKey] = DailyForecast(
          date: existing.date,
          maxTemp: existing.maxTemp > forecast.maxTemp ? existing.maxTemp : forecast.maxTemp,
          minTemp: existing.minTemp < forecast.minTemp ? existing.minTemp : forecast.minTemp,
          description: existing.description,
          icon: existing.icon,
          humidity: existing.humidity,
          windSpeed: existing.windSpeed,
          precipitationChance: existing.precipitationChance,
        );
      }
    }

    return dailyMap.values.take(5).toList();
  }

  String get dayName {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Tomorrow';

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[date.weekday - 1];
  }
}

/// Hourly forecast data
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final String description;
  final String icon;
  final int precipitationChance;
  final double windSpeed;

  HourlyForecast({
    required this.time,
    required this.temperature,
    required this.description,
    required this.icon,
    required this.precipitationChance,
    required this.windSpeed,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temperature: (json['main']['temp'] ?? 0.0).toDouble(),
      description: json['weather'][0]['description'] ?? '',
      icon: json['weather'][0]['icon'] ?? '',
      precipitationChance: ((json['pop'] ?? 0.0) * 100).round(),
      windSpeed: (json['wind']?['speed'] ?? 0.0).toDouble(),
    );
  }

  static List<HourlyForecast> listFromJson(Map<String, dynamic> forecastJson) {
    List<dynamic> list = forecastJson['list'] ?? [];
    return list.take(24).map((item) => HourlyForecast.fromJson(item)).toList();
  }

  String get hourText {
    return '${time.hour.toString().padLeft(2, '0')}:00';
  }

  // Add weatherId property for compatibility
  int get weatherId {
    // Extract weather ID from icon or description
    // This is a simplified approach
    if (icon.contains('01')) return 800; // Clear
    if (icon.contains('02')) return 801; // Few clouds
    if (icon.contains('03')) return 802; // Scattered clouds
    if (icon.contains('04')) return 803; // Broken clouds
    if (icon.contains('09')) return 520; // Shower rain
    if (icon.contains('10')) return 500; // Rain
    if (icon.contains('11')) return 200; // Thunderstorm
    if (icon.contains('13')) return 600; // Snow
    if (icon.contains('50')) return 701; // Mist
    return 800; // Default to clear
  }
}

/// Astronomy data (sun and moon information)
class AstronomyData {
  final DateTime sunrise;
  final DateTime sunset;
  final String moonPhase;
  final int timezone;

  AstronomyData({
    required this.sunrise,
    required this.sunset,
    required this.moonPhase,
    required this.timezone,
  });

  factory AstronomyData.fromJson(Map<String, dynamic> json) {
    return AstronomyData(
      sunrise: DateTime.fromMillisecondsSinceEpoch(json['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sunset'] * 1000),
      moonPhase: json['moonPhase'] ?? '🌑',
      timezone: json['timezone'] ?? 0,
    );
  }

  String get sunriseTime {
    return '${sunrise.hour.toString().padLeft(2, '0')}:${sunrise.minute.toString().padLeft(2, '0')}';
  }

  String get sunsetTime {
    return '${sunset.hour.toString().padLeft(2, '0')}:${sunset.minute.toString().padLeft(2, '0')}';
  }

  String get daylightDuration {
    final duration = sunset.difference(sunrise);
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    return '${hours}h ${minutes}m';
  }

  String get moonPhaseName {
    switch (moonPhase) {
      case '🌑': return 'New Moon';
      case '🌒': return 'Waxing Crescent';
      case '🌓': return 'First Quarter';
      case '🌔': return 'Waxing Gibbous';
      case '🌕': return 'Full Moon';
      case '🌖': return 'Waning Gibbous';
      case '🌗': return 'Last Quarter';
      case '🌘': return 'Waning Crescent';
      default: return 'Unknown';
    }
  }
}
