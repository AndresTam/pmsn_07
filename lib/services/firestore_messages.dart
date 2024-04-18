import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreMessage{
  final CollectionReference _messagesCollection = FirebaseFirestore.instance.collection('messages');

  //Add user information
  Future<void> createMessage(String chatId, String message, String sender, String date, String type) async {
    try{
      await _messagesCollection.doc().set({
        'chatID': chatId,
        'message': message,
        'sender': sender,
        'date': date,
        'type': type,
      });
      print('Message created succesfully');
    } catch (e){
      print('Error creating message: $e');
    }
  }

  //Get messages from firestore
  Future<List<Map<String, dynamic>>> getMessages() async {
    try{
      QuerySnapshot querySnapshot = await _messagesCollection.get();
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