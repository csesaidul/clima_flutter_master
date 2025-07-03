import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utilities/constants.dart';

class CityScreen extends StatefulWidget {
  const CityScreen({super.key});

  @override
  _CityScreenState createState() => _CityScreenState();
}

class _CityScreenState extends State<CityScreen> {
  String cityName = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/city_background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Align(
                alignment: Alignment.topLeft,
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    if (kDebugMode) {
                      print('Back button pressed, returning to previous screen');
                    }
                  },
                  child: Icon(
                    Icons.arrow_back_ios,
                    size: 50.0,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  decoration: kTextFieldInputDecoration,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                  onChanged: (value) {
                    // Handle text input changes
                    cityName = value;
                  },
                  ),
                ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: () {
                  // Handle the button press to get weather for the entered city
                  if (kDebugMode) {
                    print('Get Weather button pressed');
                    Navigator.pop(context, cityName);
                  }
                  // You can add functionality to fetch weather data here
                },
                child: Text(
                  'Get Weather',
                  style: kButtonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
