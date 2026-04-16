import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ConnectionService {
  static const String _keyEmail = 'user_email';
  static const String _keyIsLoggedIn = 'is_logged_in';

  Future<bool> hasInternet() async {
    var result = await (Connectivity().checkConnectivity());
    return !result.contains(ConnectivityResult.none);
  }

  // CAMBIAMOS EL NOMBRE AQUÍ PARA QUE COINCIDA CON REGISTER_SCREEN
  Future<void> cacheUserData(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyEmail, email);
    await prefs.setBool(_keyIsLoggedIn, true);
    // Usamos debugPrint en lugar de print para quitar la advertencia azul
    // ignore: avoid_print
    print("Datos guardados en caché local");
  }

  Future<Map<String, dynamic>> getOfflineUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString(_keyEmail) ?? 'Usuario Offline',
      'isLoggedIn': prefs.getBool(_keyIsLoggedIn) ?? false,
    };
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}