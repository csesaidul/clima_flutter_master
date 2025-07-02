import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NetworkHelper {
  final String url;

  NetworkHelper(this.url);

  Future<dynamic> getData() async {
    try {
      http.Response response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        String data = response.body;
        var decodedData = jsonDecode(data);

        if (kDebugMode) {
          print('Weather data fetched successfully');
        }
        return decodedData;
      } else {
        if (kDebugMode) {
          print('Error fetching weather data: ${response.statusCode}');
        }
        throw Exception(
          'Weather API returned status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in getData(): $e');
      }
      throw Exception('Failed to fetch weather data: $e');
    }
  }
}