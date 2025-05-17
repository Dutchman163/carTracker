import 'dart:async';
import 'package:geolocator/geolocator.dart';

class LocationService {
  Position? _lastPosition;
  double _totalDistance = 0;
  StreamSubscription<Position>? _subscription;
  
  Future<void> startTracking(
    Stream<Position> positionStream,
    Function(double) onDistanceUpdated,
  ) async {
  _subscription = positionStream.listen((Position position) {
    if (position.accuracy > 20) {
      return; 
    }

    if (_lastPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );
      if (distance >= 5) {
        _totalDistance += distance;
        onDistanceUpdated(_totalDistance);
        _lastPosition = position; // Alleen bij geldige afstand updaten
      }
    } else {
      _lastPosition = position;
    }
  });
}


  void stopTracking() {
    _subscription?.cancel();
    _totalDistance = 0;
    _lastPosition = null;
  }

  double getTotalDistance() {
    return _totalDistance;
  }
}
