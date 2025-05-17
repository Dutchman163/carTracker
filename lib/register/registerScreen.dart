import 'package:car_tracer/login/loginScreen.dart';
import 'package:flutter/material.dart';
import 'authService.dart'; // pas het pad aan als nodig

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = await _authService.registerWithEmailAndPassword(email, password);
      
      MaterialPageRoute(builder: (context) => const LoginScreen());
    } catch (e) {
      print("Fout bij registreren: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Registratie mislukt: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registreren')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'E-mailadres'),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Wachtwoord'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Maak account aan'),
            ),
          ],
        ),
      ),
    );
  }
}
