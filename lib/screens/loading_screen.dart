import 'package:clima_flutter_master/services/location.dart';
import 'package:clima_flutter_master/services/networking.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  Position? currentPosition;
  LocationServices locationService = LocationServices();
  bool isLoading = true;
  String? errorMessage;
  final String _apiKey = "4ab244dbb64533a71879e35e8017c667"; // Added the API key
  var _weatherData;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      if (kDebugMode) {
        print('Starting location request...');
      }

      // Request current location
      currentPosition = await locationService.getCurrentLocation();

      if (kDebugMode) {
        print('Location obtained: Lat=${currentPosition!.latitude}, Lon=${currentPosition!.longitude}');
      }

      /// Call getData() AFTER location is obtained
      var url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=${currentPosition!.latitude}&lon=${currentPosition!.longitude}&appid=$_apiKey&units=metric',
      );

      if (kDebugMode) {
        print('API URL: $url');
        print('API Key: $_apiKey');
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
          print('Description: ${_weatherData['weather']?[0]?['description'] ?? 'Unknown'}');
        }
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location or weather data: $e');
        print('Error type: ${e.runtimeType}');
        if (e.toString().contains('401')) {
          print('API Key issue detected - please check if the API key is valid');
        }
      }

      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting location...'),
                ],
              )
            : errorMessage != null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error, color: Colors.red, size: 48),
                      SizedBox(height: 16),
                      Text('Error: $errorMessage'),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isLoading = true;
                            errorMessage = null;
                          });
                          _getLocation();
                        },
                        child: Text('Retry'),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.location_on, color: Colors.green, size: 48),
                      SizedBox(height: 16),
                      Text('Location found!'),
                      if (currentPosition != null)
                        Text(
                          'Lat: ${currentPosition!.latitude.toStringAsFixed(4)}\n'
                          'Lon: ${currentPosition!.longitude.toStringAsFixed(4)}',
                          textAlign: TextAlign.center,
                        ),
                    ],
                  ),
      ),
    );
  }

  @override
  void dispose() {
    locationService.dispose();
    super.dispose();
  }
}
