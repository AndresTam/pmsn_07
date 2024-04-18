import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChats{
  final CollectionReference _chatsCollection = FirebaseFirestore.instance.collection('chats');

  //Get chats from firestore
  Future<List<Map<String, dynamic>>> getChats() async {
    try {
      QuerySnapshot querySnapshot = await _chatsCollection.get();
      List<Map<String, dynamic>> chatsList = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        chatsList.add(userData);
      });
      //print(chatsList);
      return chatsList;
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
}