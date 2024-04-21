import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreGroups{
  final CollectionReference _groupsCollection = FirebaseFirestore.instance.collection('groups');

  //Create new group in firestore
  Future<void> createGroup(String groupId, String asignature, String description, String profesorId, List<String> participants, String imageUrl) async {
    try{
      await _groupsCollection.doc(groupId).set({
        'groupID': groupId,
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
}