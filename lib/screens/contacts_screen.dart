import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_07/services/firestore_chats.dart';
import 'package:pmsn_07/services/firestore_contacts.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/util/snackbar.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final FirestoreChats _firestoreChats = FirestoreChats();
  final FirestoreUser _firestoreUser = FirestoreUser();
  final FirestoreContacts _firestoreContacts = FirestoreContacts();
  final String auth = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contactos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showNewContactBottomSheet(context);
            },
          )
        ],
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
                      return ListTile(title: Text('Cargando...'));
                    } else if (userSnapshot.hasError) {
                      return ListTile(title: Text('Error al obtener usuario'));
                    } else if (!userSnapshot.hasData || userSnapshot.data == null) {
                      return ListTile(title: Text('Usuario no encontrado'));
                    } else {
                      // Obtener datos del usuario
                      var userData = userSnapshot.data!;
                      String userId = userData['userID'] ?? '';
                      String name = userData['name'] ?? '';
                      String email = userData['email'] ?? '';
                      String career = userData['career'] ?? '';
                      String position = userData['position'] ?? '';
                      String sentence = userData['sentence'] ?? '';
                      String imgProfile = userData['imgProfile'] ?? '';

                      return ListTile(
                        leading: CircleAvatar(
                          backgroundImage: NetworkImage(imgProfile),
                        ),
                        title: Text(name),
                        subtitle: Text(sentence),
                        onTap: () {
                          _showContactInfoBottomSheet(context, userId, name, email, career, position, sentence, imgProfile);
                        },
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }

  void _showNewContactBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled:
          true,
      builder: (BuildContext context) {
        final screenHeight = MediaQuery.of(context).size.height;
        final bottomSheetHeight = screenHeight * 0.8;
        return Container(
          height: bottomSheetHeight,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Añadir Contacto',
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    hintText: 'Introduce el correo electrónico',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    List<String> contactList = await _firestoreContacts.getContacts(auth);
                    if (contactList.isEmpty) {
                      String? contactId = await _firestoreUser.getUserIdFromEmail(emailController.text);
                      List<String> contactArray = [];
                      contactArray.add(contactId.toString());
                      _firestoreContacts.createContacts(auth, contactArray);
                    } else {
                      String? contactId = await _firestoreUser.getUserIdFromEmail(emailController.text);
                      List<String> contactArray = [];
                      contactArray.add(contactId.toString());
                      _firestoreContacts.updateContacts(auth, contactArray);
                    }
                    setState(() {});
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16),
                  ),
                  child: const Text(
                    'Agregar Contacto',
                    style: TextStyle(
                        fontSize: 20),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showContactInfoBottomSheet(BuildContext context, String userId, String name, String email, String career, String position, String sentence, String imgProfile) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(40, 20, 40, 80), // Agregamos margen inferior
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: CircleAvatar(
                  backgroundImage: NetworkImage(imgProfile),
                  radius: 80,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Container(
                height: 2,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(vertical: 10),
              ),
              Center(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  career,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  position,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  sentence,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20), // Espacio antes del botón
              ElevatedButton(
                child: const Text(
                  'Enviar Mensaje',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
                ),
                onPressed: () async {
                  String chatId = auth + userId;
                  int exist = await _firestoreChats.createChat(chatId, auth, userId);
                  if(exist == 1){
                    Navigator.pushNamed(context, "/messages",
                      arguments: {
                        'chatID': auth+userId,
                        'userID': auth,
                        'name': name,
                        'userID1': auth,
                    });
                  } else if(exist == 2){
                    Navigator.pushNamed(context, "/messages",
                      arguments: {
                        'chatID': userId+auth,
                        'userID': auth,
                        'name': name,
                        'userID1': auth,
                    });
                  } else if(exist == 2){
                    Navigator.pushNamed(context, "/messages",
                      arguments: {
                        'chatID': chatId,
                        'userID': auth,
                        'name': name,
                        'userID1': auth,
                    });
                  } else {
                    showSnackBar(context, "No se pudo enviar el mensaje");
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}