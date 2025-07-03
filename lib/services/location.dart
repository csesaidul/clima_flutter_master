import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';

/// A service class for handling location-related operations.
/// Provides methods to get current location with proper permission handling.
class LocationServices {
  Position? _position;
  StreamSubscription<Position>? _positionStreamSubscription;

  /// Gets the current position if available
  Position? get currentPosition => _position;

  /// Gets the current latitude
  double? get latitude => _position?.latitude;

  /// Gets the current longitude
  double? get longitude => _position?.longitude;

  /// Determines the current position of the device with permission handling.
  /// Enhanced for web compatibility
  ///
  /// Returns a [Position] object containing latitude and longitude.
  /// Throws [LocationServiceDisabledException] if location services are disabled.
  /// Throws [PermissionDeniedException] if location permissions are denied.
  Future<Position> getCurrentLocation() async {
    try {
      if (kIsWeb) {
        // Enhanced web location handling
        return await _getWebLocation();
      } else {
        // Mobile/desktop location handling
        _position = await _determinePosition();
        return _position!;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting location: $e');
      }
      // Fallback to a default location if location fails
      return _getFallbackLocation();
    }
  }

  /// Internal method to handle the location determination process
  Future<Position> _determinePosition() async {
    // Test if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceDisabledException('Location services are disabled.');
    }

    // Check and request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw PermissionDeniedException('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw PermissionDeniedException(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
    }

    // Get the current position with modern settings
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  /// Web-specific location handling with better error management
  Future<Position> _getWebLocation() async {
    try {
      // Check if location services are available on web
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (kDebugMode) {
          print('Location services are disabled on web. Using fallback location.');
        }
        return _getFallbackLocation();
      }

      // Check permission with web-specific handling
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (kDebugMode) {
            print('Location permission denied on web. Using fallback location.');
          }
          return _getFallbackLocation();
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (kDebugMode) {
          print('Location permission permanently denied on web. Using fallback location.');
        }
        return _getFallbackLocation();
      }

      // Web-optimized location settings
      const LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: Duration(seconds: 10), // Shorter timeout for web
      );

      _position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(
        Duration(seconds: 15), // Overall timeout
        onTimeout: () {
          if (kDebugMode) {
            print('Location request timed out on web. Using fallback location.');
          }
          return _getFallbackLocation();
        },
      );

      return _position!;
    } catch (e) {
      if (kDebugMode) {
        print('Web location error: $e. Using fallback location.');
      }
      return _getFallbackLocation();
    }
  }

  /// Fallback location (Dhaka, Bangladesh) when location services fail
  Position _getFallbackLocation() {
    if (kDebugMode) {
      print('Using fallback location: Dhaka, Bangladesh');
    }

    _position = Position(
      longitude: 90.4125,
      latitude: 23.8103,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    return _position!;
  }

  /// Checks if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Checks the current permission status
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  /// Requests location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Opens the app settings page for location permissions
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Opens the location settings page
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Gets the last known position without requesting a new one
  /// Useful for getting cached location data quickly
  Future<Position?> getLastKnownPosition() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Gets location with custom accuracy settings
  /// [accuracy] - desired location accuracy level
  /// [timeoutSeconds] - maximum time to wait for location
  Future<Position> getLocationWithAccuracy({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int timeoutSeconds = 15,
  }) async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: accuracy == LocationAccuracy.high ? 10 : 100,
    );

    try {
      _position = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      ).timeout(Duration(seconds: timeoutSeconds));
      return _position!;
    } on TimeoutException {
      throw Exception('Location request timed out after $timeoutSeconds seconds');
    }
  }

  /// Calculates distance between two points in meters
  /// [lat1], [lon1] - first point coordinates
  /// [lat2], [lon2] - second point coordinates
  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Calculates bearing between two points in degrees
  /// [lat1], [lon1] - start point coordinates
  /// [lat2], [lon2] - end point coordinates
  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.bearingBetween(lat1, lon1, lat2, lon2);
  }

  /// Starts listening to location changes
  /// [onLocationUpdate] - callback function when location changes
  /// [accuracy] - desired location accuracy
  /// [distanceFilter] - minimum distance change to trigger update (in meters)
  void startLocationStream({
    required Function(Position) onLocationUpdate,
    Function(String)? onError,
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10,
  }) {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: accuracy,
      distanceFilter: distanceFilter,
    );

    _positionStreamSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (Position position) {
        _position = position;
        onLocationUpdate(position);
      },
      onError: (error) {
        if (onError != null) {
          onError(error.toString());
        }
      },
    );
  }

  /// Stops listening to location changes
  void stopLocationStream() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// Checks if location streaming is active
  bool get isLocationStreamActive => _positionStreamSubscription != null;

  /// Gets formatted location string for display
  /// Returns "Lat: XX.XXXX, Lon: XX.XXXX" or "Location not available"
  String getFormattedLocation({int decimals = 4}) {
    if (_position != null) {
      return 'Lat: ${_position!.latitude.toStringAsFixed(decimals)}, '
          'Lon: ${_position!.longitude.toStringAsFixed(decimals)}';
    }
    return 'Location not available';
  }

  /// Gets location accuracy in meters (if available)
  double? get accuracy => _position?.accuracy;

  /// Gets altitude in meters (if available)
  double? get altitude => _position?.altitude;

  /// Gets speed in m/s (if available)
  double? get speed => _position?.speed;

  /// Gets heading in degrees (if available)
  double? get heading => _position?.heading;

  /// Gets timestamp of the last position update
  DateTime? get timestamp => _position?.timestamp;

  /// Validates if the current location is within given bounds
  /// [northLat], [southLat], [eastLon], [westLon] - boundary coordinates
  bool isLocationWithinBounds({
    required double northLat,
    required double southLat,
    required double eastLon,
    required double westLon,
  }) {
    if (_position == null) return false;

    final lat = _position!.latitude;
    final lon = _position!.longitude;

    return lat <= northLat &&
        lat >= southLat &&
        lon <= eastLon &&
        lon >= westLon;
  }

  /// Checks if location data is fresh (within specified minutes)
  /// [maxAgeMinutes] - maximum age of location data in minutes
  bool isLocationFresh({int maxAgeMinutes = 5}) {
    if (_position?.timestamp == null) return false;

    final now = DateTime.now();
    final locationTime = _position!.timestamp;
    final difference = now.difference(locationTime).inMinutes;

    return difference <= maxAgeMinutes;
  }

  /// Clears cached location data
  void clearCache() {
    _position = null;
  }

  /// Gets comprehensive location info as a map
  Map<String, dynamic> getLocationInfo() {
    if (_position == null) {
      return {'status': 'No location available'};
    }

    return {
      'latitude': _position!.latitude,
      'longitude': _position!.longitude,
      'accuracy': _position!.accuracy,
      'altitude': _position!.altitude,
      'speed': _position!.speed,
      'heading': _position!.heading,
      'timestamp': _position!.timestamp.toIso8601String(),
      'formattedLocation': getFormattedLocation(),
      'isFresh': isLocationFresh(),
    };
  }

  /// Disposes resources and stops any active streams
  void dispose() {
    stopLocationStream();
    clearCache();
  }
}

/// Exception thrown when location services are disabled
class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

/// Exception thrown when location permissions are denied
class PermissionDeniedException implements Exception {
  final String message;
  PermissionDeniedException(this.message);

  @override
  String toString() => 'PermissionDeniedException: $message';
}