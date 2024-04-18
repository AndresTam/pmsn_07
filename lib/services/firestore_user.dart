import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  final CollectionReference _userCollection = FirebaseFirestore.instance.collection('users');

  //Add user information
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

  //Get user information
  Future<Map<String, dynamic>?> getUser(String userID) async {
    try {
      DocumentSnapshot docSnapshot = await _userCollection.doc(userID).get();
      Map<String, dynamic> userInfo;
      if(docSnapshot.exists){
        userInfo = docSnapshot.data() as Map<String, dynamic>;
        return userInfo;
      } else{
        return null;
      }
    } catch (e) {
      print('Error getting users: $e');
      return null;
    }
  }
}