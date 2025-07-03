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
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  decoration: kTextFieldInputDecoration,
                  style: TextStyle(fontSize: 18.0, color: Colors.black),
                  onChanged: (value) {
                    setState(() {
                      cityName = value.trim(); // Trim whitespace
                    });
                  },
                  onSubmitted: (value) {
                    // Allow Enter key to submit
                    if (value.trim().isNotEmpty) {
                      Navigator.pop(context, value.trim());
                    }
                  },
                ),
              ),
              SizedBox(height: 20.0),
              TextButton(
                onPressed: cityName.isEmpty ? null : () {
                  // Only allow submission if city name is not empty
                  if (kDebugMode) {
                    print('Get Weather button pressed for city: $cityName');
                  }

                  Navigator.pop(context, cityName);
                },
                child: Text(
                  'Get Weather',
                  style: kButtonTextStyle.copyWith(
                    color: cityName.isEmpty ? Colors.grey : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
