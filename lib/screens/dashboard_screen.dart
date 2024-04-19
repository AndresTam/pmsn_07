import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_07/services/firestore_chats.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/util/snackbar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirestoreChats _firestoreChats = FirestoreChats();
  final FirestoreUser _firestoreUser = FirestoreUser();
  final String auth = FirebaseAuth.instance.currentUser!.uid;
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    bool shouldIncludeChat(Map<String, dynamic> chat, String targetChatID) {
      return chat['chatID'].contains(targetChatID);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chats',
          style: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
        ),
        backgroundColor: const Color.fromRGBO(88, 104, 117, 1),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add,
              color: Color.fromRGBO(246, 237, 220, 1),
            ), // Icono de suma (+)
            onPressed: () {
              _showNewChatBottomSheet(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(88, 104, 117, 1),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _firestoreChats.getChats(),
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                final chatsList = snapshot.data ?? [];
                final targetChatID =
                    auth; // Especifica el chat ID que deseas buscar

                // Filtra la lista para incluir solo los chats que cumplan la condición
                final filteredChatsList = chatsList
                    .where((chat) => shouldIncludeChat(chat, targetChatID))
                    .toList();
                return ListView.builder(
                  itemCount: filteredChatsList.length,
                  itemBuilder: (BuildContext context, int index) {
                    final chat = filteredChatsList[index];
                    var userID = '';
                    if (chat['participant1'] == auth) {
                      userID = chat['participant2'];
                    } else if (chat['participant2'] == auth) {
                      userID = chat['participant1'];
                    }
                    return FutureBuilder<Map<String, dynamic>?>(
                      future: _firestoreUser.getUser(userID),
                      builder: (BuildContext context,
                          AsyncSnapshot<Map<String, dynamic>?> userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const ListTile(
                            title: Text('Loading...'),
                          );
                        } else if (userSnapshot.hasError) {
                          return const ListTile(
                            title: Text('Error loading user'),
                          );
                        } else {
                          final userData = userSnapshot.data!;
                          return Column(
                            children: [
                              ListTile(
                                leading: ClipOval(
                                    child: Image.network(
                                  userData['imgProfile'],
                                  width: 43,
                                  height: 43,
                                  fit: BoxFit.cover,
                                )),
                                title: Text(
                                  userData['name'],
                                  style: const TextStyle(
                                      color: Color.fromRGBO(246, 237, 220, 1)),
                                ),
                                // subtitle: Text(
                                //   chat['lastMessage'],
                                //   style: const TextStyle(color: Color.fromRGBO(189, 214, 210, 1)),
                                // ),
                                // trailing: Text(
                                //   chat['time'],
                                //   style: const TextStyle(color: Color.fromRGBO(189, 214, 210, 1)),
                                // ),
                                onTap: () {
                                  print(
                                      "chatID: ${chat['chatID']} \n userID: ${auth} \n name: ${userData['name']}");
                                  // Aquí puedes manejar la navegación al chat específico
                                  Navigator.pushNamed(context, "/messages",
                                      arguments: {
                                        'chatID': chat['chatID'],
                                        'userID': auth,
                                        'name': userData['name']
                                      });
                                },
                              ),
                              _buildCustomDivider(),
                            ],
                          );
                        }
                      },
                    );
                  },
                );
              }
            }),
      ),
      bottomNavigationBar: BottomAppBar(
        color: const Color.fromARGB(
            255, 50, 62, 71), // Color de fondo del menú inferior
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.camera_alt,
                color: Color.fromRGBO(246, 237, 220, 1),
              ),
              onPressed: () {
                // Implementar acción de cámara
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.chat,
                color: Color.fromRGBO(246, 237, 220, 1),
              ),
              onPressed: () {
                setState(() {});
                Navigator.pushNamed(context, "/dash");
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Color.fromRGBO(246, 237, 220, 1),
              ),
              onPressed: () {
                // Implementar acción de ajustes
                Navigator.pushNamed(
                  context,
                  "/settings",
                  arguments: {
                    'userID': auth,
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomDivider() {
    return Container(
      margin: const EdgeInsets.only(left: 73.0, right: 5),
      height: 1.0,
      color:
          const Color.fromRGBO(227, 229, 215, 1), // Color de la línea del borde
    );
  }

  void _showNewChatBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled:
          true, // Hacer que el BottomSheet ocupe toda la pantalla
      builder: (BuildContext context) {
        // Obtiene la altura total de la pantalla
        final screenHeight = MediaQuery.of(context).size.height;

        // Establece una altura fija para el BottomSheet
        final bottomSheetHeight =
            screenHeight * 0.8; // Ejemplo: 80% de la pantalla

        return Container(
          height: bottomSheetHeight,
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Nuevo Chat',
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
                    print(emailController.text);
                    final String? userId = await _firestoreUser
                        .getUserIdFromEmail(emailController.text);
                    if (userId != auth && userId != '' && userId != '') {
                      final String chatId = auth + userId!;
                      print(chatId);
                      _firestoreChats.createChat(chatId, auth, userId);
                    } else if (userId == auth) {
                      showSnackBar(
                          context, 'No puedes enviarte mensajes a ti mismo');
                    } else {
                      showSnackBar(
                          context, 'Hubo un error, intentalo de nuevo');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 16), // Ajusta la altura del botón
                  ),
                  child: const Text(
                    'Empezar a chatear',
                    style: TextStyle(
                        fontSize: 20), // Ajusta el tamaño del texto del botón
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
