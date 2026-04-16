// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/welcome_screen.dart';
import 'firebase_options.dart';

void main() async {
  // Asegura que los canales nativos de Flutter estén listos
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase con las opciones de tu proyecto
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Agregamos el constructor con 'super.key' para eliminar la advertencia de VS Code
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Visionary AI',
      debugShowCheckedModeBanner: false,
      // Aplicamos el tema global de tu aplicación
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      // La primera pantalla que verá Nathalia al abrir la app
      home: const WelcomeScreen(), 
    );
  }
}