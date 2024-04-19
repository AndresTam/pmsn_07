import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future createAcount(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      return (userCredential.user?.uid);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return 1;
      } else if (e.code == 'email-already-in-use') {
        return 2;
      }
    } catch (e) {
      print(e);
    }
  }

  Future singinEmailAndPassword(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      final user = userCredential.user;
      if (user?.uid != null) {
        return user?.uid;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        return 1;
      } else if (e.code == 'wrong-password') {
        return 2;
      }
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      print('Sing Out Exitoso');
    } catch (e) {
      print('No se pudo cerra sesion');
    }
  }
}
