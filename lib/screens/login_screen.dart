import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../services/connection_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final ConnectionService _connection = ConnectionService();
  bool _isLoading = false;

  Future<void> _loginUser() async {
    // Verificar conexión antes de intentar loguear
    bool isOnline = await _connection.hasInternet();
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sin conexión. No puedes iniciar sesión en línea."), backgroundColor: Colors.orange),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Iniciar sesión en Firebase
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Guardar en caché para que la próxima vez entre offline
      if (userCredential.user != null) {
        await _connection.cacheUserData(userCredential.user!.email!);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Error al iniciar sesión";
      if (e.code == 'user-not-found') message = "No existe un usuario con este correo.";
      if (e.code == 'wrong-password') message = "Contraseña incorrecta.";
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.redAccent));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(backgroundColor: kWhite, elevation: 0, iconTheme: const IconThemeData(color: kDarkGrey)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: kPasteledBlue),
            const SizedBox(height: 20),
            const Text("Iniciar Sesión", style: kTitleStyle),
            const SizedBox(height: 30),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: "Correo", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Contraseña", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 30),
            _isLoading 
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _loginUser,
                    style: ElevatedButton.styleFrom(backgroundColor: kPasteledBlue),
                    child: const Text("Entrar", style: TextStyle(color: kDarkGrey, fontWeight: FontWeight.bold)),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}