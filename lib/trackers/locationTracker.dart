import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/services/locationService.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';

class LocationTracker extends StatefulWidget {
  const LocationTracker({super.key});

  @override
  State<LocationTracker> createState() => _LocationTrackerState();
}

class _LocationTrackerState extends State<LocationTracker> {
  final LocationService _locationService = LocationService();
  bool _isTracking = false;

  @override
  void dispose() {
    _locationService.stopTracking(); // Stop tracking bij verlaten
    super.dispose();
  }

  Future<void> _checkPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Locatieservices zijn uitgeschakeld')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Locatietoestemming geweigerd')),
      );
      return;
    }
  }

  void _startTracking() async {
    await _checkPermissions();

    setState(() {
      _isTracking = true;
    });

    final positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 5, // Update elke 5 meter
      ),
    );

    _locationService.startTracking(positionStream, (totalDistance) {
      setState(() {
        // Update de UI met de nieuwe afstand
      });
    });
  }

  void _stopTracking() {
    setState(() {
      _isTracking = false;
    });
    _locationService.stopTracking();
  }

  void saveTripToFirestore() async {
  await FirebaseFirestore.instance.collection('trips').add({
    'startTime': Timestamp.now(),
    'endTime': Timestamp.now(),
    'distance': 10.5, // voorbeelddata
  });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Afstandstracker')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Totaal: ${(_locationService.getTotalDistance() / 1000).toStringAsFixed(2)} km',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isTracking ? _stopTracking : _startTracking,
              child: Text(_isTracking ? 'Stop met meten' : 'Start met meten'),
            ),
            ElevatedButton(
            onPressed: saveTripToFirestore,
            child: const Text('Sla rit op'),
          ),
          ],
        ),
      ),
    );
  }
}
