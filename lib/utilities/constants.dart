import 'package:flutter/material.dart';

const kTempTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 100.0,
);

const kMessageTextStyle = TextStyle(
  fontFamily: 'Spartan MB',
  fontSize: 60.0,
);

const kButtonTextStyle = TextStyle(
  fontSize: 30.0,
  fontFamily: 'Spartan MB',
);

const kConditionTextStyle = TextStyle(
  fontSize: 100.0,
);

final kTextFieldInputDecoration = InputDecoration(
  icon: const Icon(
    Icons.location_city,
    color: Colors.white,
    size: 30.0,
  ),
  filled: true,
  fillColor: Colors.white.withOpacity(0.8),
  hintText: 'Enter City Name',
  hintStyle: const TextStyle(
    color: Colors.black54,
    fontSize: 18.0,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(10.0),
    borderSide: BorderSide.none,
  ),
);