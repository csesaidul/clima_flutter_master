import 'package:flutter/material.dart';

class DailyForecastCard extends StatelessWidget {
  final String day;
  final String icon;
  final String maxTemp;
  final String minTemp;

  const DailyForecastCard({
    super.key,
    required this.day,
    required this.icon,
    required this.maxTemp,
    required this.minTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              day,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            Text(
              icon,
              style: const TextStyle(
                fontSize: 24,
              ),
            ),
            Text(
              '$maxTemp° / $minTemp°',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

