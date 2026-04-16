import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Importación necesaria para Logout
import '../services/connection_service.dart';
import '../core/constants.dart';
import 'welcome_screen.dart'; // Para redirigir al cerrar sesión

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ConnectionService _connection = ConnectionService();
  
  String userEmail = "Cargando...";
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // 1. Verificamos internet
    bool hasNet = await _connection.hasInternet();
    
    // 2. Recuperamos datos del caché local
    final cache = await _connection.getOfflineUser();

    if (mounted) {
      setState(() {
        isOffline = !hasNet;
        userEmail = cache['email'] ?? "Usuario Invitado";
      });
    }
  }

  // FUNCIÓN PARA CERRAR SESIÓN
  Future<void> _logout() async {
    try {
      // 1. Cerrar sesión en Firebase
      await FirebaseAuth.instance.signOut();
      
      // 2. Limpiar el caché local (SharedPreferences)
      await _connection.clearCache();
      
      // 3. Regresar a la pantalla de bienvenida
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const WelcomeScreen()),
          (route) => false, // Elimina todas las pantallas previas de la pila
        );
      }
    } catch (e) {
      debugPrint("Error al cerrar sesión: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: const Text("Visionary Cash Check"),
        backgroundColor: isOffline ? Colors.orange : kPasteledBlue,
        elevation: 0,
        centerTitle: true,
        // AÑADIMOS EL BOTÓN DE LOGOUT EN EL APPBAR
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: kDarkGrey),
            onPressed: _logout,
            tooltip: "Cerrar Sesión",
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icono dinámico según la conexión
            Icon(
              isOffline ? Icons.cloud_off_rounded : Icons.check_circle_outline,
              size: 100,
              color: isOffline ? Colors.orange : Colors.green,
            ),
            const SizedBox(height: 20),
            
            Text(
              isOffline ? "Modo Offline Activo" : "Conectado a la Nube",
              style: TextStyle(
                color: isOffline ? Colors.orange : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 40),
            
            const Text("Bienvenido de vuelta:", style: kSubtitleStyle),
            Text(userEmail, style: kTitleStyle),
            
            const SizedBox(height: 50),
            
            // Botón principal
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Implementar lógica de cámara TFLite
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Iniciando escáner de billetes...")),
                );
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text("Identificar Billete"),
              style: ElevatedButton.styleFrom(
                backgroundColor: kPasteledBlue,
                foregroundColor: kDarkGrey,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}