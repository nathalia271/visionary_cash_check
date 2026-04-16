import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/constants.dart';
import '../services/connection_service.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  // Instancia del servicio
  final ConnectionService _connection = ConnectionService();
  bool _isLoading = false;

  Future<void> _registerUser() async {
    // --- NIVEL 1: MANEJO DE ERRORES DE CONEXIÓN ---
    bool isOnline = await _connection.hasInternet();
    
    if (!isOnline) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.wifi_off, color: Colors.white),
                SizedBox(width: 10),
                Text("Sin conexión. Revisa tu Wi-Fi o datos."),
              ],
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return; 
    }

    setState(() => _isLoading = true);

    try {
      // --- NIVEL 2: FIREBASE AUTH ---
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // --- NIVEL 3: GUARDAR EN CACHÉ (MODO OFFLINE) ---
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
      // --- MANEJO DE ERRORES ESPECÍFICOS DE FIREBASE ---
      String errorMessage = "Error al registrarse";
      
      if (e.code == 'network-request-failed') {
        errorMessage = "Error de red. Conexión inestable.";
      } else if (e.code == 'email-already-in-use') {
        errorMessage = "Este correo ya está en uso.";
      } else if (e.code == 'weak-password') {
        errorMessage = "La contraseña es muy corta.";
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite, 
        elevation: 0, 
        iconTheme: const IconThemeData(color: kDarkGrey)
      ),
      body: SingleChildScrollView( // Evita errores de teclado
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Icon(Icons.person_add_outlined, size: 80, color: kPasteledBlue),
              const SizedBox(height: 20),
              const Text("Crea tu cuenta", style: kTitleStyle),
              const Text("Únete a Visionary Cash Check", style: kSubtitleStyle),
              const SizedBox(height: 40),
              
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Correo electrónico", 
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 15),
              
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Contraseña", 
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 30),

              _isLoading 
                ? const CircularProgressIndicator(color: kPasteledBlue)
                : SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _registerUser,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPasteledBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text(
                        "Registrarme Ahora", 
                        style: TextStyle(color: kDarkGrey, fontSize: 16, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}