import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChats{
  final CollectionReference _chatsCollection = FirebaseFirestore.instance.collection('chats');

  Future<List<Map<String, dynamic>>> getChats() async {
    try {
      QuerySnapshot querySnapshot = await _chatsCollection.get();
      List<Map<String, dynamic>> productsList = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        productsList.add(userData);
      });
      //print(chatsList);
      return productsList;
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
}