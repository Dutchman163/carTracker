import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '/services/locationService.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:car_tracer/drawer/appDrawer';

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
    await startForegroundTask();
    setState(() {
      _isTracking = true;
    });

    final positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
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
     FlutterForegroundTask.stopService();
    _locationService.stopTracking();
  }

  void saveTripToFirestore() async {
    var rideValue = {(_locationService.getTotalDistance() / 1000).toStringAsFixed(2)};
    var total = double.parse(rideValue.first);
    if (total == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geen afstand om op te slaan')),
      );
      return;
    }
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return;
  await FirebaseFirestore.instance.collection('trips').add({
    
    'startTime': Timestamp.now(),
    'endTime': Timestamp.now(),
    'distance':  total,
    'user': FirebaseFirestore.instance.collection('users').doc(userId),
  });

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final carRef = userDoc.data()?['car'] as DocumentReference?;
    if (carRef != null) {
    final carDoc = await carRef.get();
    final carData = carDoc.data() as Map<String, dynamic>;
    final currentDistance = (carData['totalDistance'] ?? 0).toDouble();

    // Voeg afstand toe aan de auto
    await carRef.update({
      'totalDistance': currentDistance + total,
    });
  }

    setState(() {
      _isTracking = false;
    });
    _locationService.stopTracking();
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Afstandstracker')),
      drawer: const  AppDrawer(),
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

Future<void> startForegroundTask() async {
 FlutterForegroundTask.init(
  androidNotificationOptions: AndroidNotificationOptions(
    channelId: 'gps_tracking_channel',
    channelName: 'GPS Tracking',
    channelDescription: 'Deze service houdt je locatie bij.',
    channelImportance: NotificationChannelImportance.LOW,
    priority: NotificationPriority.LOW,
    iconData: NotificationIconData(
      resType: ResourceType.mipmap,
      resPrefix: ResourcePrefix.ic,
      name: 'launcher', // Zorg dat dit icoon bestaat
    ),
  ),
  iosNotificationOptions: const IOSNotificationOptions(
    showNotification: true,
    playSound: false,
  ),
  foregroundTaskOptions: const ForegroundTaskOptions(
    interval: 5000,
    isOnceEvent: false,
    allowWakeLock: true,
    allowWifiLock: true,
  ),
);


  await FlutterForegroundTask.startService(
    notificationTitle: 'Locatie wordt bijgehouden',
    notificationText: 'Je afstand wordt gemeten...',
  );
}
}