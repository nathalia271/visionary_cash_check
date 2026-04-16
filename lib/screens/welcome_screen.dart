import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/connection_service.dart'; // Importante para el caché
import '../core/constants.dart';
import 'register_screen.dart';
import 'login_screen.dart';
import 'home_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  final AuthService _authService = AuthService();
  final ConnectionService _connection = ConnectionService(); // Para verificar caché
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  // Si ya hay alguien logueado en caché, saltamos la bienvenida
  Future<void> _checkExistingSession() async {
    final session = await _connection.getOfflineUser();
    if (session['isLoggedIn'] == true && context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Bienvenido a\nVisionary Cash Check",
      "desc": "Tu asistente inteligente para la identificación y autenticación de billetes en tiempo real.",
      "icon": "👁️",
    },
    {
      "title": "Identificación Rápida",
      "desc": "Utilizamos Inteligencia Artificial para reconocer denominaciones de billetes de forma instantánea.",
      "icon": "💵",
    },
    {
      "title": "Seguridad Garantizada",
      "desc": "Detectamos marcas de seguridad para ayudarte a verificar la autenticidad de tu dinero.",
      "icon": "🛡️",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            const Icon(Icons.visibility_outlined, size: 80, color: kPasteledBlue),
            
            Expanded(
              flex: 3,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) => _OnboardingContent(
                  title: _onboardingData[index]["title"]!,
                  desc: _onboardingData[index]["desc"]!,
                  icon: _onboardingData[index]["icon"]!,
                ),
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _onboardingData.length,
                (index) => buildDot(index),
              ),
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                children: [
                  // 1. BOTÓN GOOGLE
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        User? user = await _authService.signInWithGoogle();
                        if (user != null && context.mounted) {
                          // Guardamos en caché que inició sesión con Google
                          await _connection.cacheUserData(user.email ?? "Google User");
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                          );
                        }
                      },
                      icon: const Icon(Icons.login, color: kDarkGrey),
                      label: const Text(
                        "Iniciar sesión con Google",
                        style: TextStyle(color: kDarkGrey, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPasteledBlue,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),

                  // 2. BOTÓN INICIAR SESIÓN (NUEVO)
                  // Para los que ya se registraron con correo
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: kPasteledBlue, width: 2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                      child: const Text(
                        "Ya tengo cuenta / Entrar",
                        style: TextStyle(color: kDarkGrey, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 3. ENLACE A REGISTRO
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    child: const Text(
                      "¿Eres nuevo? Regístrate aquí",
                      style: TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  AnimatedContainer buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 5),
      height: 8,
      width: _currentPage == index ? 20 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? kPasteledBlue : Colors.grey[300],
        borderRadius: BorderRadius.circular(5),
      ),
    );
  }
}

class _OnboardingContent extends StatelessWidget {
  final String title, desc, icon;
  const _OnboardingContent({required this.title, required this.desc, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 60)),
          const SizedBox(height: 20),
          Text(title, textAlign: TextAlign.center, style: kTitleStyle),
          const SizedBox(height: 15),
          Text(desc, textAlign: TextAlign.center, style: kSubtitleStyle),
        ],
      ),
    );
  }
}