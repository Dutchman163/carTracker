import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectedCarWidget extends StatelessWidget {
  const SelectedCarWidget({super.key});

  Future<String> _getOrCreateCar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Gebruiker niet ingelogd');
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnapshot = await userDocRef.get();

    // Check of er al een auto gekoppeld is
    final existingCarRef = userSnapshot.data()?['car'];

    if (existingCarRef != null) {
      // Haal eventueel de autogegevens op
      final carSnapshot = await (existingCarRef as DocumentReference).get();
      final carData = carSnapshot.data() as Map<String, dynamic>;
      return carData['name'] ?? 'Onbekende auto';
    } else {
      // Voeg nieuwe auto toe
      final newCar = {
        'name': 'Nieuwe auto',
        'owner': userDocRef,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final newCarRef = await FirebaseFirestore.instance.collection('cars').add(newCar);

      // Update user document met verwijzing naar de auto
      await userDocRef.update({'car': newCarRef});

      return 'Nieuwe auto toegevoegd';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: _getOrCreateCar(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Fout: ${snapshot.error}');
        } else {
          return Text('Gekozen auto: ${snapshot.data}');
        }
      },
    );
  }
}
