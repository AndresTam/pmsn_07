import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCalls {
  final CollectionReference _callsCollection =
      FirebaseFirestore.instance.collection('calls');

  //Create new chat in firestore
  Future<void> createCall(String chatID, String call, String userID,
      String userName, String date) async {
    try {
      await _callsCollection.doc().set({
        'call': call,
        'chatID': chatID,
        'userID': userID,
        'userName': userName,
        'date': date,
      });
      print('Message created succesfully');
    } catch (e) {
      print('Error creating message: $e');
    }
  }

  Future<String?> getCallEnable(String chatID, String date) async {
    try {
      QuerySnapshot querySnapshot = await _callsCollection
          .where('chatID', isEqualTo: chatID)
          .where('date', isEqualTo: date)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['call'] as String?;
      } else {
        return 'No se encontro la llamada';
      }
    } catch (e) {
      print('Error getting user: $e');
      return null;
    }
  }

  Future<void> updateCall(String chatID, String date, String call) async {
    try {
      QuerySnapshot querySnapshot = await _callsCollection
          .where('chatID', isEqualTo: chatID)
          .where('date', isEqualTo: date)
          .get();
      querySnapshot.docs.forEach((doc) async {
        await doc.reference.update({'call': call});
      });
      print('llamada actualizada $chatID');
    } catch (e) {
      print('Error actualizando la llamada actualizada $chatID: $e');
    }
  }
}
