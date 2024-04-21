import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pmsn_07/services/firestore_contacts.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/services/firestore_groups.dart';
import 'package:pmsn_07/util/snackbar.dart';

class GroupCreationScreen extends StatefulWidget {
  const GroupCreationScreen({super.key});

  @override
  State<GroupCreationScreen> createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final FirestoreUser _firestoreUser = FirestoreUser();
  final FirestoreContacts _firestoreContacts = FirestoreContacts();
  final FirestoreGroups _firestoreGroups = FirestoreGroups();
  final String auth = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController emailController = TextEditingController();
  List<String> participantsList = [];
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    participantsList.remove(auth);
    participantsList.add(auth);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes'),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: _firestoreContacts.getContacts(auth),
        builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error al obtener contactos'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay contactos disponibles'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (BuildContext context, int index) {
                return FutureBuilder(
                  future: _firestoreUser.getUser(snapshot.data![index]),
                  builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>?> userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const ListTile(title: Text('Cargando...'));
                    } else if (userSnapshot.hasError) {
                      return const ListTile(title: Text('Error al obtener usuario'));
                    } else if (!userSnapshot.hasData || userSnapshot.data == null) {
                      return const ListTile(title: Text('Usuario no encontrado'));
                    } else {
                      var userData = userSnapshot.data!;
                      String userId = userData['userID'] ?? '';
                      String name = userData['name'] ?? '';
                      String sentence = userData['sentence'] ?? '';
                      String imgProfile = userData['imgProfile'] ?? '';

                      return CheckboxListTile(
                        title: Text(name),
                        subtitle: Text(sentence),
                        value: participantsList.contains(userId),
                        onChanged: (bool? isChecked) {
                          setState(() {
                            if (isChecked!) {
                              participantsList.add(userId);
                            } else {
                              participantsList.remove(userId);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.trailing,
                        secondary: CircleAvatar(
                          backgroundImage: NetworkImage(imgProfile),
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (participantsList.length > 1) {
            showSnackBar(context, 'Guardando Datos');
            _firestoreGroups.createGroup(args?['groupId'], args?['asignature'], args?['description'], auth, participantsList, args?['image']);
            showSnackBar(context, 'Datos Guardados');
            Navigator.pushNamed(context, "/dash");
          } else {
            print('Ningún usuario seleccionado');
          }
        },
        child: const Text('Crear Grupo', textAlign: TextAlign.center,),
      ),
    );
  }
}