import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../services/weather.dart';
import '../utilities/constants.dart';
import 'city_screen.dart';

WeatherModel weather = WeatherModel();

class LocationScreen extends StatefulWidget {
  final dynamic weatherData;
  final dynamic locationService;
  final dynamic currentPosition;
  const LocationScreen({
    super.key,
    this.weatherData,
    this.locationService,
    this.currentPosition,
  });

  @override
  _LocationScreenState createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  int? temperature;
  String? cityName;
  String? weatherIcon;
  String? weatherMessage; // Mood will changed based on weather conditions

  @override
  void initState() {
    if (kDebugMode) {
      print(widget.weatherData);
    }
    updateUI(widget.weatherData);
    super.initState();
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
      });
      return;
    }

    setState(() {
      double temp = weatherData['main']?['temp'] ?? 0.0;
      temperature = temp.round();
      cityName = weatherData['name'] ?? 'Unknown';
      int condition = weatherData['weather']?[0]?['id'] ?? 0;
      weatherIcon = weather.getWeatherIcon(condition);
      weatherMessage = weather.getMessage(temperature ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/location_background.jpg'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.white.withOpacity(0.8),
              BlendMode.dstATop,
            ),
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  TextButton(
                    onPressed: () {
                      setState(() {
                        updateUI(widget.weatherData);
                        kDebugMode
                            ? print(
                                'Location button is Pressed\nUpdated Weather Data: ${widget.weatherData}',
                              )
                            : null;
                      });
                    },
                    child: Icon(Icons.near_me, size: 50.0),
                  ),
                  TextButton(
                    onPressed: () async {
                      String cityName = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => CityScreen()),
                      );
                      if (kDebugMode) {
                        print('City name entered: $cityName');
                      }
                      if (cityName != null && cityName.isNotEmpty) {
                        var weatherData = await weather.getCityWeather(cityName);
                        updateUI(weatherData);
                      } else {
                        if (kDebugMode) {
                          print('No city name entered, using current location');
                        }
                        var weatherData = await weather.getLocationWeather();
                        updateUI(weatherData);
                      }
                    },
                    child: Icon(Icons.location_city, size: 50.0),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(left: 15.0),
                child: Row(
                  children: <Widget>[
                    Text('$temperature° ', style: kTempTextStyle),
                    Text(weatherIcon.toString(), style: kConditionTextStyle),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 15.0),
                child: Text(
                  "$weatherMessage in $cityName!",
                  textAlign: TextAlign.right,
                  style: kMessageTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// {coord: {lon: 90.7515, lat: 24.9347}, weather: [{id: 804, main: Clouds, description: overcast clouds, icon: 04n}], base: stations, main: {temp: 26.71, feels_like: 29.92, temp_min: 26.71, temp_max: 26.71, pressure: 1003, humidity: 90, sea_level: 1003, grnd_level: 1003}, visibility: 10000, wind: {speed: 4.76, deg: 119, gust: 9.59}, clouds: {all: 100}, dt: 1751561548, sys: {country: BD, sunrise: 1751497891, sunset: 1751547032}, timezone: 21600, id: 1185116, name: Netrakona, cod: 200}
