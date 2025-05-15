import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'trackers/locationTracker.dart'; // Import de Locat

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (defaultTargetPlatform == TargetPlatform.windows) {
    await Firebase.initializeApp(
      options: const FirebaseOptions (
        apiKey: "AIzaSyBTRWm5GF3egLBw71JoosJODS9c8I2_go4",
        authDomain: "cartracker-ecaee.firebaseapp.com",
        projectId: "cartracker-ecaee",
        storageBucket: "cartracker-ecaee.firebasestorage.app",
        messagingSenderId: "59916178907",
        appId: "1:59916178907:web:e468810538bb3b7afa43fe"
      )
    );
  } else {
    await Firebase.initializeApp(); // Voor Android/iOS
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LocationTracker(), 
    );
  }
}
