import 'package:firebase_auth/firebase_auth.dart';

class AuthService{
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future createAcount (String email, String password) async {
    try{
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      print(userCredential.user);
      return (userCredential.user?.uid);
    } on FirebaseAuthException catch(e) {
      if(e.code == 'weak-password'){
        print("The password provided is too weak");
        return 1;
      } else if(e.code == 'email-already-in-use'){
        print("This account already exist for that email");
        return 2;
      }
    } catch (e){
      print(e);
    }
  }

  Future singinEmailAndPassword (String email, String password) async {
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final user = userCredential.user;
      if(user?.uid != null){
        return user?.uid;
      }
    } on FirebaseAuthException catch(e) {
      if(e.code == 'user-not-found'){
        return 1;
      } else if(e.code == 'wrong-password'){
        return 2;
      }
    }
  }
}