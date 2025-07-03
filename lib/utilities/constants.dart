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

const kTextFieldInputDecoration = InputDecoration(
  filled: true,
  fillColor: Colors.white,
  icon: Icon(
    Icons.location_city,
    color: Colors.white,
  ),
  hintText: 'Enter City Name',
  hintStyle: TextStyle(
    color: Colors.grey,
  ),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
    borderSide: BorderSide.none,
  ),
);

// Responsive Helper Class
class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 650 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static double getWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double getHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;

  // Responsive font sizes
  static double getTempFontSize(BuildContext context) {
    if (isDesktop(context)) return 120.0;
    if (isTablet(context)) return 100.0;
    return 80.0;
  }

  static double getMessageFontSize(BuildContext context) {
    if (isDesktop(context)) return 70.0;
    if (isTablet(context)) return 60.0;
    return 50.0;
  }

  static double getConditionFontSize(BuildContext context) {
    if (isDesktop(context)) return 120.0;
    if (isTablet(context)) return 100.0;
    return 80.0;
  }

  // Responsive padding
  static EdgeInsets getMainPadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.symmetric(horizontal: 40.0, vertical: 30.0);
    }
    if (isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 30.0, vertical: 25.0);
    }
    return const EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0);
  }

  // Responsive button size
  static double getButtonSize(BuildContext context) {
    if (isDesktop(context)) return 60.0;
    if (isTablet(context)) return 55.0;
    return 50.0;
  }

  // Missing methods for city_screen.dart
  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isDesktop(context)) {
      return const EdgeInsets.all(32.0);
    }
    if (isTablet(context)) {
      return const EdgeInsets.all(24.0);
    }
    return const EdgeInsets.all(16.0);
  }

  static double getResponsiveIconSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.2;
    if (isTablet(context)) return baseSize * 1.1;
    return baseSize;
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isDesktop(context)) return baseSize * 1.3;
    if (isTablet(context)) return baseSize * 1.15;
    return baseSize;
  }
}
