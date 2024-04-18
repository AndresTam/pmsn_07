import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChats{
  final CollectionReference _chatsCollection = FirebaseFirestore.instance.collection('chats');

  //Create new chat in firestore
  Future<void> createChat(String chatID, String participant1, String participant2) async {
    try{
      await _chatsCollection.doc(chatID).set({
        'chatID': chatID,
        'participant1': participant1,
        'participant2': participant2,
      });
      print('Chat created succesfully');
    } catch (e){
      print('Error creating user: $e');
    }
  }

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