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
  final Stream<List<Map<String, dynamic>>> _chatsStream =
      FirestoreChats().getChatsStream();
  final List<String> profesor = ['maestro', 'profesor', 'docente'];
  final List<String> student = ['estudiante', 'alumno'];

  Future<Map<String, dynamic>> _getUserData(String userID) async {
    Map<String, dynamic>? userData = await _firestoreUser.getUser(userID);
    return userData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    bool shouldIncludeChat(Map<String, dynamic> chat, String targetChatID) {
      return chat['chatID'].contains(targetChatID);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Chats',
            style: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
          ),
          backgroundColor: const Color.fromRGBO(88, 104, 117, 1),
          centerTitle: true,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Color.fromRGBO(246, 237, 220, 1),
              ), // Icono de suma (+)
              onPressed: () async {
                Map<String, dynamic>? data = await _getUserData(auth);
                String email = data['email'] as String;
                RegExp regex = RegExp(r'^[a-zA-Z]+\.[a-zA-Z]+@');
                if (regex.hasMatch(email)) {
                  _showNewGroupBottomSheet(
                      context); // Mostrar modal para profesor
                } else {
                  _showNewChatBottomSheet(context); // Mostrar modal para alumno
                }
              },
            ),
          ],
        ),
        body: Container(
          decoration: const BoxDecoration(
            color: Color.fromRGBO(88, 104, 117, 1),
          ),
          child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatsStream,
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
                            print(userData);
                            return Column(
                              children: [
                                ListTile(
                                  leading: ClipOval(
                                    child: Image.network(
                                      userData['imgProfile'],
                                      width: 43,
                                      height: 43,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    userData['name'],
                                    style: const TextStyle(
                                        color:
                                            Color.fromRGBO(246, 237, 220, 1)),
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
                                    Navigator.pushNamed(context, "/messages",
                                        arguments: {
                                          'chatID': chat['chatID'],
                                          'userID': auth,
                                          'name': userData['name'],
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
                  Icons.perm_contact_cal,
                  color: Color.fromRGBO(246, 237, 220, 1),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/contacts");
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.group,
                  color: Color.fromRGBO(246, 237, 220, 1),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, "/groups");
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.chat,
                  color: Color.fromRGBO(246, 237, 220, 1),
                ),
                onPressed: () {
                  setState(() {});
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
      isScrollControlled: true,
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
                    final String? userId = await _firestoreUser
                        .getUserIdFromEmail(emailController.text);
                    if (userId != auth && userId != '' && userId != '') {
                      final String chatId = auth + userId!;
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

  void _showNewGroupBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
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
                    final String? userId = await _firestoreUser
                        .getUserIdFromEmail(emailController.text);
                    if (userId != auth && userId != '' && userId != '') {
                      final String chatId = auth + userId!;
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
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Empezar a chatear',
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(height: 30),
                const Text(
                  'O',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    Navigator.pushNamed(context, "/groupInfo");
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Crear Grupo',
                    style: TextStyle(fontSize: 20),
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
