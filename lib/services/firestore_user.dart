import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreUser {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  //Add user information
  Future<void> createUser(
    String userID,
    String name,
    String email,
    String career,
    String position,
    String sentence,
    String imgProfile,
  ) async {
    try {
      await _userCollection.doc(userID).set({
        'userID': userID,
        'name': name,
        'email': email,
        'career': career,
        'position': position,
        'sentence': sentence,
        'imgProfile': imgProfile,
      });
      print('User created succesfully');
    } catch (e) {
      print('Error creating user: $e');
    }
  }

  //Funcion para actualizar el perfil
  Future<void> updateProfile(
    String userID,
    String name,
    String career,
    String position,
    String sentence,
    String imgProfile,
  ) async {
    try {
      await _userCollection.doc(userID).update({
        'name': name,
        'career': career,
        'position': position,
        'sentence': sentence,
        'imgProfile': imgProfile,
      });
      print('Perfil updated successfully!');
    } catch (e) {
      print('Error updating Perfil: $e');
    }
  }

  //Get user information
  Future<Map<String, dynamic>?> getUser(String userID) async {
    try {
      DocumentSnapshot docSnapshot = await _userCollection.doc(userID).get();
      Map<String, dynamic> userInfo;
      if (docSnapshot.exists) {
        userInfo = docSnapshot.data() as Map<String, dynamic>;
        return userInfo;
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting users: $e');
      return null;
    }
  }

  //Get user information by email
  Future<String?> getUserIdFromEmail(String email) async {
    try {
      QuerySnapshot querySnapshot =
          await _userCollection.where('email', isEqualTo: email).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['userID'] as String?;
      } else {
        return 'No se encontro el usuario';
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  //Get nameuser information by id
  Future<String?> getUserNameByID(String userID) async {
    try {
      QuerySnapshot querySnapshot =
          await _userCollection.where('userID', isEqualTo: userID).get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['name'] as String?;
      } else {
        return 'No se encontro el usuario';
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }
}
