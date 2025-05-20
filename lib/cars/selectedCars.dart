import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SelectedCarWidget extends StatefulWidget {
  const SelectedCarWidget({super.key});

  @override
  State<SelectedCarWidget> createState() => _SelectedCarWidgetState();
}

class _SelectedCarWidgetState extends State<SelectedCarWidget> {
  final TextEditingController _carNameController = TextEditingController();
  String? _carName;
  bool _isLoading = true;
  bool _hasCar = false;

  @override
  void initState() {
    super.initState();
    _checkForExistingCar();
  }

  Future<void> _checkForExistingCar() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw Exception('Gebruiker niet ingelogd');
    }

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);
    final userSnapshot = await userDocRef.get();
    final carRef = userSnapshot.data()?['car'];

    if (carRef != null && carRef is DocumentReference) {
      final carSnapshot = await carRef.get();
      final carData = carSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _carName = carData['name'];
        _hasCar = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
        _hasCar = false;
      });
    }
  }

  Future<void> _addCar(String name) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final userDocRef = FirebaseFirestore.instance.collection('users').doc(uid);

    final newCar = {
      'name': name,
      'createdAt': FieldValue.serverTimestamp(),
    };

    final carRef = await FirebaseFirestore.instance.collection('cars').add(newCar);

    await userDocRef.update({'car': carRef});

    setState(() {
      _carName = name;
      _hasCar = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CircularProgressIndicator();
    }

    if (_hasCar) {
      return Text('Gekozen auto: $_carName');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Voer de kenteken in voor je auto:'),
        TextField(
          controller: _carNameController,
          decoration: const InputDecoration(labelText: 'Kenteken'),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () {
            final name = _carNameController.text.trim();
            if (name.isNotEmpty) {
              _addCar(name);
            }
          },
          child: const Text('Auto toevoegen'),
        ),
      ],
    );
  }
}
