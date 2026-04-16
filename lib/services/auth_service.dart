import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Login con Google y Registro en Firestore
  Future<User?> signInWithGoogle() async {
    try {
      // 1. Iniciar el login de Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null; // El usuario canceló

      // 2. Obtener los detalles de autenticación
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // 3. Crear una nueva credencial para Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // 4. Iniciar sesión en Firebase con la credencial
      UserCredential result = await _auth.signInWithCredential(credential);
      User? user = result.user;

      // 5. Guardar/Actualizar los datos del usuario en Firestore
      if (user != null) {
        await _db.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'nombre': user.displayName,
          'email': user.email,
          'fecha_registro': FieldValue.serverTimestamp(), // Marca de tiempo del servidor
        }, SetOptions(merge: true)); // Merge evita sobrescribir si ya existe
      }

      return user;
    } catch (e) {
      print("Error en AuthService (signInWithGoogle): $e");
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }
}