import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';

class LocationService extends ChangeNotifier {
  Position? _currentPosition;
  Timer? _locationTimer;
  bool _isLocationEnabled = false;

  Position? get currentPosition => _currentPosition;
  bool get isLocationEnabled => _isLocationEnabled;

  /// Initialize location service and request permissions
  Future<bool> initialize() async {
    try {
      // Check location permission
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
        if (!status.isGranted) {
          return false;
        }
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return false;
      }

      _isLocationEnabled = true;
      await _getCurrentLocation();
      _startLocationUpdates();
      return true;
    } catch (e) {
      print('Error initializing location service: $e');
      return false;
    }
  }

  /// Get current location once
  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _currentPosition = position;
      notifyListeners();

      // Simulate server update (bonus feature)
      print('Location update sent to server: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  /// Start continuous location updates every 10 seconds
  void _startLocationUpdates() {
    _locationTimer = Timer.periodic(Duration(seconds: 10), (timer) {
      _getCurrentLocation();
    });
  }

  /// Stop location updates
  void stopLocationUpdates() {
    _locationTimer?.cancel();
    _locationTimer = null;
  }

  /// Calculate distance between two positions
  double getDistanceBetween(Position pos1, Position pos2) {
    return Geolocator.distanceBetween(
      pos1.latitude,
      pos1.longitude,
      pos2.latitude,
      pos2.longitude,
    );
  }

  /// Check if driver is within specified radius of target location
  bool isWithinRadius(Position targetLocation, double radiusInMeters) {
    if (_currentPosition == null) return false;

    double distance = getDistanceBetween(_currentPosition!, targetLocation);
    return distance <= radiusInMeters;
  }

  /// Get formatted distance text
  String getDistanceText(Position targetLocation) {
    if (_currentPosition == null) return 'Location unknown';

    double distance = getDistanceBetween(_currentPosition!, targetLocation);
    if (distance < 1000) {
      return '${distance.round()} m away';
    } else {
      return '${(distance / 1000).toStringAsFixed(1)} km away';
    }
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }
}