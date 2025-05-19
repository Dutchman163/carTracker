import 'package:car_tracer/cars/selectedCars.dart';
import 'package:car_tracer/drawer/appDrawer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class Cars extends StatefulWidget {
  const Cars({super.key});
  
  State<Cars> createState() => _Cars();
}

class _Cars extends State<Cars> {
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Auto\'s'),),
      drawer: const  AppDrawer(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SelectedCarWidget()
          ],
        ),
      ),
    );
  }
}