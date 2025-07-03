import 'dart:math';

import 'package:clima_flutter_master/widgets/additional_details_grid.dart';
import 'package:clima_flutter_master/widgets/daily_forecast_card.dart';
import 'package:clima_flutter_master/widgets/hourly_forecast_card.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/weather.dart';
import '../utilities/constants.dart';
import 'city_screen.dart';

WeatherModel weather = WeatherModel();

class LocationScreen extends StatefulWidget {
  const LocationScreen({
    super.key,
    this.weatherData,
    this.locationService,
    this.currentPosition,
  });

  final dynamic weatherData;
  final dynamic locationService;
  final dynamic currentPosition;

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int? temperature;
  String? cityName;
  String? weatherIcon;
  String? weatherMessage; // Mood will changed based on weather conditions
  int? humidity;
  int? pressure;
  double? windSpeed;
  int? feelsLike;
  List<dynamic>? hourlyForecast;
  List<dynamic>? dailyForecast;
  String? sunrise;
  String? sunset;
  String? visibility;

  @override
  void initState() {
    super.initState();
    updateUI(widget.weatherData);
  }

  void updateUI(dynamic weatherData) {
    if (weatherData == null) {
      if (kDebugMode) {
        print('Weather data is null');
      }
      setState(() {
        temperature = 0;
        cityName = '';
        weatherIcon = 'Error';
        weatherMessage = 'Unable to get weather data';
        humidity = 0;
        pressure = 0;
        windSpeed = 0.0;
        feelsLike = 0;
        hourlyForecast = [];
        dailyForecast = [];
        sunrise = 'N/A';
        sunset = 'N/A';
        visibility = 'N/A';
      });
      return;
    }

    setState(() {
      var currentWeather = weatherData['current'];
      var forecastList = weatherData['forecast']?['list'];

      double temp = currentWeather['main']?['temp'] ?? 0.0;
      temperature = temp.round();
      cityName = currentWeather['name'] ?? 'Unknown';
      int condition = currentWeather['weather']?[0]?['id'] ?? 0;
      weatherIcon = weather.getWeatherIcon(condition);
      weatherMessage = weather.getMessage(temperature ?? 0);
      humidity = currentWeather['main']?['humidity'] ?? 0;
      pressure = currentWeather['main']?['pressure'] ?? 0;
      windSpeed = currentWeather['wind']?['speed'] ?? 0.0;
      double feelsLikeTemp = currentWeather['main']?['feels_like'] ?? 0.0;
      feelsLike = feelsLikeTemp.round();
      hourlyForecast = forecastList ?? [];

      // Sunrise/Sunset
      int sunriseTimestamp = currentWeather['sys']?['sunrise'] ?? 0;
      int sunsetTimestamp = currentWeather['sys']?['sunset'] ?? 0;
      int timezoneOffset = currentWeather['timezone'] ?? 0;

      sunrise = _formatTimestamp(sunriseTimestamp, timezoneOffset);
      sunset = _formatTimestamp(sunsetTimestamp, timezoneOffset);

      // Visibility
      int visibilityInMeters = currentWeather['visibility'] ?? 0;
      visibility = '${(visibilityInMeters / 1000).toStringAsFixed(1)} km';

      // Daily Forecast
      if (forecastList != null) {
        final Map<String, dynamic> dailyData = {};
        for (var forecast in forecastList) {
          final date = DateTime.fromMillisecondsSinceEpoch(
            forecast['dt'] * 1000,
          );
          final dayKey = '${date.year}-${date.month}-${date.day}';
          if (!dailyData.containsKey(dayKey)) {
            dailyData[dayKey] = {
              'min': forecast['main']['temp_min'],
              'max': forecast['main']['temp_max'],
              'icons': [forecast['weather'][0]['id']],
              'day': DateFormat('EEEE').format(date), // EEEE for full day name
            };
          } else {
            dailyData[dayKey]['min'] = min(
              dailyData[dayKey]['min'],
              forecast['main']['temp_min'],
            );
            dailyData[dayKey]['max'] = max(
              dailyData[dayKey]['max'],
              forecast['main']['temp_max'],
            );
            dailyData[dayKey]['icons'].add(forecast['weather'][0]['id']);
          }
        }

        // Find the most frequent icon for the day
        dailyForecast = dailyData.values.map((dayData) {
          final mostFrequentIcon = _getMostFrequent(dayData['icons']);
          return {
            'day': dayData['day'],
            'icon': weather.getWeatherIcon(mostFrequentIcon),
            'maxTemp': dayData['max'].round(),
            'minTemp': dayData['min'].round(),
          };
        }).toList();

        // Remove today's forecast if it's in the list
        final today = DateFormat('EEEE').format(DateTime.now());
        dailyForecast?.removeWhere((forecast) => forecast['day'] == today);
      } else {
        dailyForecast = [];
      }
    });
  }

  String _formatTimestamp(int timestamp, int timezoneOffset) {
    if (timestamp == 0) return 'N/A';
    final dateTime = DateTime.fromMillisecondsSinceEpoch(
      (timestamp + timezoneOffset) * 1000,
      isUtc: true,
    );
    return DateFormat.jm().format(dateTime); // e.g., 5:08 PM
  }

  int _getMostFrequent(List<dynamic> list) {
    if (list.isEmpty) return 800; // Default to clear sky
    var counts = <int, int>{};
    for (var item in list) {
      counts[item] = (counts[item] ?? 0) + 1;
    }
    int? maxItem;
    int? maxCount;
    counts.forEach((item, count) {
      if (maxCount == null || count > maxCount!) {
        maxCount = count;
        maxItem = item;
      }
    });
    return maxItem!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),
              BlendMode.dstATop,
            ),
          ),
        ),
        constraints: const BoxConstraints.expand(),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      TextButton(
                        onPressed: () async {
                          var weatherData = await weather
                              .getDetailedWeatherData();
                          updateUI(weatherData);
                          if (kDebugMode) {
                            print(
                              'Location button is Pressed\nUpdated Weather Data: $weatherData',
                            );
                          }
                        },
                        child: const Icon(Icons.near_me, size: 50.0),
                      ),
                      TextButton(
                        onPressed: () async {
                          var cityName = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CityScreen(),
                            ),
                          );
                          if (kDebugMode) {
                            print('City name entered: $cityName');
                          }
                          if (cityName != null && cityName.isNotEmpty) {
                            var weatherData = await weather
                                .getDetailedWeatherData(cityName: cityName);
                            updateUI(weatherData);
                          } else {
                            if (kDebugMode) {
                              print(
                                'No city name entered, using current location',
                              );
                            }
                            var weatherData = await weather
                                .getDetailedWeatherData();
                            updateUI(weatherData);
                          }
                        },
                        child: const Icon(Icons.location_city, size: 50.0),
                      ),
                    ],
                  ),
                  if (cityName != null && cityName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Text(
                        cityName!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      children: <Widget>[
                        Text('$temperature° ', style: kTempTextStyle),
                        Text(weatherIcon ?? '', style: kConditionTextStyle),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (hourlyForecast != null && hourlyForecast!.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: hourlyForecast!.length > 8
                            ? 8
                            : hourlyForecast!.length,
                        itemBuilder: (context, index) {
                          var forecast = hourlyForecast![index];
                          var time = forecast['dt_txt']
                              .split(' ')[1]
                              .substring(0, 5);
                          var icon = weather.getWeatherIcon(
                            forecast['weather'][0]['id'],
                          );
                          var temp = forecast['main']['temp']
                              .round()
                              .toString();
                          return HourlyForecastCard(
                            time: time,
                            icon: icon,
                            temperature: temp,
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 20),
                  _buildDailyForecast(),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: AdditionalDetailsGrid(
                      details: {
                        'Sunrise': sunrise ?? 'N/A',
                        'Sunset': sunset ?? 'N/A',
                        'Humidity': '${humidity ?? 'N/A'}%',
                        'Wind Speed':
                            '${windSpeed?.toStringAsFixed(1) ?? 'N/A'} m/s',
                        'Pressure': '${pressure ?? 'N/A'} hPa',
                        'Visibility': visibility ?? 'N/A',
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 15.0),
                  //   child: Container(
                  //     alignment: Alignment.centerRight,
                  //     width: double.infinity,
                  //     child: Expanded(
                  //       child: Text(
                  //         "$weatherMessage in $cityName!",
                  //         textAlign: TextAlign.right,
                  //         style: kMessageTextStyle,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDailyForecast() {
    if (dailyForecast == null || dailyForecast!.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '5-Day Forecast',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dailyForecast!.length > 5 ? 5 : dailyForecast!.length,
            itemBuilder: (context, index) {
              var forecast = dailyForecast![index];
              return DailyForecastCard(
                day: forecast['day'],
                icon: forecast['icon'],
                maxTemp: forecast['maxTemp'].toString(),
                minTemp: forecast['minTemp'].toString(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// {coord: {lon: 90.7515, lat: 24.9347}, weather: [{id: 804, main: Clouds, description: overcast clouds, icon: 04n}], base: stations, main: {temp: 26.71, feels_like: 29.92, temp_min: 26.71, temp_max: 26.71, pressure: 1003, humidity: 90, sea_level: 1003, grnd_level: 1003}, visibility: 10000, wind: {speed: 4.76, deg: 119, gust: 9.59}, clouds: {all: 100}, dt: 1751561548, sys: {country: BD, sunrise: 1751497891, sunset: 1751547032}, timezone: 21600, id: 1185116, name: Netrakona, cod: 200}
