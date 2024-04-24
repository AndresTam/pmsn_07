import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreContacts{
  final CollectionReference _contactsCollection = FirebaseFirestore.instance.collection("contacts");

  //Add contacts
  Future<void> createContacts(String userID, List<String> contactID) async {
    try{
      await _contactsCollection.doc(userID).set({
        'userID': userID,
        'contactID': contactID,
      });
      print('Contact created succesfully');
    } catch (e){
      print('Error creating message: $e');
    }
  }

  //Get contacts
  Future<List<String>> getContacts(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _contactsCollection
          .where('userID', isEqualTo: userId)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return List<String>.from(querySnapshot.docs.first['contactID']);
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting contacts: $e');
      throw Exception('Error al obtener contactos');
    }
  }

  // Update contacts
  Future<void> updateContacts(String userId, List<String> contactId) async {
    try {
      List<String> existingContacts = await getContacts(userId);
      Set<String> updatedContactsSet = {...existingContacts, ...contactId};
      List<String> updatedContacts = updatedContactsSet.toList();
      await _contactsCollection.doc(userId).update({'contactID': updatedContacts,});
      print('Contact updated succesfully');
    } catch (e) {
      print('Error updating contacts: $e');
    }
  }

  //final _contactsController = StreamController<List<String>>();

  // // Método para obtener los contactos como Stream
  // Stream<List<String>> getContactsStream(String userId) {
  //   startContactsListener(userId); // Inicia la escucha de los cambios
  //   return _contactsController.stream;
  // }

  // // Inicializa y escucha los cambios en Firestore
  // void startContactsListener(String userId) {
  //   _contactsCollection
  //       .doc(userId)
  //       .snapshots()
  //       .listen((DocumentSnapshot snapshot) {
  //     if (snapshot.exists) {
  //       List<String> contacts = List<String>.from(snapshot.data()!['contactID']);
  //       _contactsController.add(contacts);
  //     } else {
  //       _contactsController.add([]);
  //     }
  //   });
  // }
}