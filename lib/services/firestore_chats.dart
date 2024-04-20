import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChats{
  final CollectionReference _chatsCollection = FirebaseFirestore.instance.collection('chats');

  //Create new chat in firestore
  Future<int> createChat(String chatID, String participant1, String participant2) async {
    try{
      bool chat1 = await chatExists(participant1 + participant2);
      bool chat2 = await chatExists(participant2 + participant1);
      if(chat1){
        print("El chat ya existe");
        return 1;
      } else if(chat2){
        print("El chat ya existe");
        return 2;
      } else{
        await _chatsCollection.doc(chatID).set({
          'chatID': chatID,
          'participant1': participant1,
          'participant2': participant2,
        });
        print('Chat created succesfully');
        return 3;
      }
    } catch (e){
      print('Error creating user: $e');
      return 4;
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

  // Define el StreamController para emitir los chats actualizados
  final _chatsController = StreamController<List<Map<String, dynamic>>>();

  // Método para inicializar y escuchar los cambios en Firestore
  void startChatsListener() {
    _chatsCollection.snapshots().listen((querySnapshot) {
      List<Map<String, dynamic>> chatsList = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
        chatsList.add(userData);
      });
      // Emite los chats actualizados al StreamController
      _chatsController.add(chatsList);
    });
  }

  // Verifica si un chat ya existe con el chatID dado
  Future<bool> chatExists(String chatID) async {
    try {
      DocumentSnapshot chatDoc = await _chatsCollection.doc(chatID).get();
      return chatDoc.exists;
    } catch (e) {
      print('Error checking chat existence: $e');
      return false;
    }
  }

  // Método para obtener los chats como Stream
  Stream<List<Map<String, dynamic>>> getChatsStream() {
    startChatsListener(); // Inicia la escucha de los cambios
    return _chatsController.stream;
  }

  // Cierra el StreamController cuando ya no se necesite
  void dispose() {
    _chatsController.close();
  }
}