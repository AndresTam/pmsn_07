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

  //Stream to update messages screen
  Stream<List<Map<String, dynamic>>> getMessagesStream(String chatID) {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('chatID', isEqualTo: chatID)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data()).toList());
  }
}