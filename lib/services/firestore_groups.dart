import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGroups{
  final CollectionReference _groupsCollection = FirebaseFirestore.instance.collection('groups');

  //Create new group in firestore
  Future<void> createGroup(String groupId, String name, String asignature, String description, String profesorId, List<String> participants, String imageUrl) async {
    try{
      await _groupsCollection.doc(groupId).set({
        'groupID': groupId,
        'name': name,
        'asignature': asignature,
        'description': description,
        'profesorID': profesorId,
        'participants': participants,
        'imageUrl': imageUrl,
      });
      print('Group created succesfully');
    } catch (e){
      print('Error creating group: $e');
    }
  }
  
  // Método para obtener todos los grupos desde Firestore
  Future<List<Map<String, dynamic>>> getGroups() async {
    try {
      QuerySnapshot querySnapshot = await _groupsCollection.get();
      List<Map<String, dynamic>> groupsList = [];
      querySnapshot.docs.forEach((doc) {
        Map<String, dynamic> groupData = doc.data() as Map<String,dynamic>;
        groupsList.add(groupData);
      });
      return groupsList;
    } catch (e) {
      print('Error getting groups: $e');
      return [];
    }
  }

  // Método para obtener solo la lista de participantes de un grupo con un ID específico
  Future<List<String>> getParticipantsList(String groupId) async {
    try {
      DocumentSnapshot groupSnapshot = await _groupsCollection.doc(groupId).get();
      if (groupSnapshot.exists) {
        Map<String, dynamic>? groupData = groupSnapshot.data() as Map<String, dynamic>?; // Casting de Object? a Map<String, dynamic>?
        if (groupData != null && groupData.containsKey('participants')) {
          List<String> participants =
              (groupData['participants'] as List).cast<String>();
          return participants;
        }
      }
      print('Group with ID $groupId not found or participants list missing.');
      return [];
    } catch (e) {
      print('Error getting participants list: $e');
      return [];
    }
  }

  // Método para actualizar la lista de participantes de un grupo con un ID específico
  Future<void> updateParticipantsList(String groupId, List<String> participantList) async {
    try {
      await _groupsCollection.doc(groupId).update({
        'participants': participantList,
      });
      print('Participants list updated successfully for group with ID $groupId');
    } catch (e) {
      print('Error updating participants list: $e');
    }
  }
}