import 'package:flutter/material.dart';
import 'package:pmsn_07/main.dart';
import 'package:pmsn_07/services/auth_service.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final FirestoreUser _firestoreUser = FirestoreUser();
  final AuthService _auth = AuthService();
  bool isSwitched = false;
  dynamic userID;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recuperar los argumentos
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    // Verificar si los argumentos no son nulos y contienen la clave 'userID'
    if (args != null && args.containsKey('userID')) {
      setState(() {
        userID = args['userID'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromRGBO(0, 138, 23, 1.0),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _firestoreUser.getUser(userID),
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, dynamic>?> userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (userSnapshot.hasError) {
            return const Center(
              child: Text('Error loading user'),
            );
          } else {
            final userData = userSnapshot.data!;

            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.all(30.0),
                    child: ClipOval(
                      child: Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Color.fromARGB(255, 255, 255, 255),
                        ),
                        child: Image.network(
                          userData['imgProfile'],
                          width: 200,
                          height: 200,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 30, right: 30),
                  child: Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(255, 255, 255, 1),
                        borderRadius: BorderRadius.all(
                          Radius.circular(20),
                        ),
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        child: Column(
                          children: [
                            // const SizedBox(height: 20),
                            ListTile(
                              title: Text(
                                '${userData['name']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${userData['email']}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.normal,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Divider(),
                            ListTile(
                              title: Text(
                                '${userData['career']}',
                                textAlign: TextAlign.justify,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text(
                                '${userData['position']}\n${userData['sentence']}',
                                textAlign: TextAlign.left,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                            Divider(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromRGBO(255, 255, 255, 1),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 30,
                        right: 30,
                      ),
                      child: SettingsList(
                        sections: [
                          SettingsSection(
                            title: Text('Sesión'),
                            tiles: <SettingsTile>[
                              SettingsTile(
                                leading: const Icon(Icons.person),
                                title: const Text('Perfil'),
                                value: const Text('Configuración de perfil'),
                                onPressed: (context) async {
                                  Navigator.pushNamed(
                                    context,
                                    "/profileConfig",
                                    arguments: {
                                      "name": userData['name'],
                                      "career": userData['career'],
                                      "position": userData['position'],
                                      "sentence": userData['sentence'],
                                      "email": userData['email'],
                                      "imgProfile": userData['imgProfile'],
                                      "userID": userData['userID'],
                                    },
                                  );
                                },
                              ),
                              SettingsTile.navigation(
                                onPressed: (context) async {
                                  await _auth.signOut();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => MyApp(),
                                    ),
                                  );
                                },
                                leading: const Icon(Icons.logout),
                                title: const Text('Cerrar sesión'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
