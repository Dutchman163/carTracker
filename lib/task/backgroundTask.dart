import 'dart:async';
import 'dart:isolate';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

void startCallback() {
  FlutterForegroundTask.setTaskHandler(MyTaskHandler());
}

class MyTaskHandler extends TaskHandler {
  StreamSubscription<Position>? _positionSub;
  double _totalDistance = 0;
  Position? _lastPosition;

  @override
  Future<void> onStart(DateTime timestamp, SendPort? sendPort) async {
    await Firebase.initializeApp();

    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
      return;
    }

    _positionSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen((position) async {
      if (position.accuracy > 20) return;

      if (_lastPosition != null) {
        final distance = Geolocator.distanceBetween(
          _lastPosition!.latitude,
          _lastPosition!.longitude,
          position.latitude,
          position.longitude,
        );
        if (distance >= 5) {
          _totalDistance += distance;
        }
      }
      _lastPosition = position;
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, SendPort? sendPort) async {
    _positionSub?.cancel();

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null && _totalDistance > 0) {
      final km = (_totalDistance / 1000).toStringAsFixed(2);
      await FirebaseFirestore.instance.collection('trips').add({
        'user': FirebaseFirestore.instance.collection('users').doc(uid),
        'distance': double.parse(km),
        'startTime': Timestamp.fromDate(timestamp),
        'endTime': Timestamp.now(),
      });
    }
  }

  @override
  Future<void> onEvent(DateTime timestamp, SendPort? sendPort) async {}
  @override
  Future<void> onButtonPressed(String id) async {}
  @override
  Future<void> onNotificationPressed() async {}
  
  @override
  void onRepeatEvent(DateTime timestamp, SendPort? sendPort) {
    // TODO: implement onRepeatEvent
  }
}
