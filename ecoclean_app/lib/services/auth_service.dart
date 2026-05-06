import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  
  static Future<User?> signInWithGoogle() async {
    try {
      
      GoogleAuthProvider googleProvider = GoogleAuthProvider();

      
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      return userCredential.user;
    } catch (e) {
      print("Kesalahan Login Google Web: $e");
      return null;
    }
  }

  
  static Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print("Gagal Logout: $e");
    }
  }
}
