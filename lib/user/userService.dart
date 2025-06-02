
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
    
Future<double> GetTotalMiles() async {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return 0.0;

  final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
  final data = userDoc.data();

  if (data == null || data['total'] == null) return 0.0;

  return (data['total'] as num).toDouble();
}
}