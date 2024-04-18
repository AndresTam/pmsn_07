import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  Future<void> createUser(String userID, String name, String career, String position, String sentence, String imgProfile) async {
    try{
      await _userCollection.doc(userID).set({
        'name': name,
        'career': career,
        'position': position,
        'sentence': sentence,
        'imgProfile': imgProfile,
      });
      print('User created succesfully');
    } catch (e){
      print('Error creating user: $e');
    }
  }
}