import 'package:clima_flutter_master/services/location.dart';
import 'package:clima_flutter_master/services/weather.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'location_screen.dart';

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
  dynamic _weatherData;

  WeatherModel weatherModel = WeatherModel();

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print('LoadingScreen initialized');
    }
    // Use addPostFrameCallback to ensure the widget is built before starting async operations
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLocationAndWeather();
    });
  }

  Future<void> _getLocationAndWeather() async {
    try {
      if (kDebugMode) {
        print('Starting location and weather request...');
      }

      // Get weather data (this includes location)
      _weatherData = await weatherModel.getLocationWeather();
      currentPosition = weatherModel.currentPosition;

      if (kDebugMode) {
        print('Weather data fetched successfully');
      }

      // Only navigate if widget is still mounted
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LocationScreen(
              weatherData: _weatherData,
              locationService: locationService,
              currentPosition: currentPosition,
            ),
          ),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location or weather data: $e');
        print('Error type: ${e.runtimeType}');
        if (e.toString().contains('401')) {
          print(
            'API Key issue detected - please check if the API key is valid',
          );
        }
      }

      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (errorMessage != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Error: $errorMessage',
                style: TextStyle(color: Colors.red, fontSize: 16.0),
                textAlign: TextAlign.center,
              ),
            )
          else ...[
            SpinKitRotatingCircle(color: Colors.white, size: 50.0),
            SizedBox(height: 20.0),
            Text(
              "Getting Location...",
              style: TextStyle(color: Colors.white, fontSize: 20.0),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    locationService.dispose();
    super.dispose();
  }
}
