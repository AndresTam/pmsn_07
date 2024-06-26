import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pmsn_07/services/firestore_groups.dart';


class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final String auth = FirebaseAuth.instance.currentUser!.uid;
  final FirestoreGroups _firestoreGroups = FirestoreGroups();
  late Future<List<Map<String, dynamic>>> _groupsFuture;

  @override
  void initState() {
    super.initState();
    _groupsFuture = _firestoreGroups.getGroups();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Grupos', style: TextStyle(color: Color.fromRGBO(246, 237, 220, 1))),
        backgroundColor: const Color.fromRGBO(88, 104, 117, 1),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(88, 104, 117, 1),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _groupsFuture,
          builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final groupsList = snapshot.data ?? [];
              final userGroups = groupsList.where((group) => group['participants'].contains(auth)).toList();
              if (userGroups.isEmpty) {
                return Center(child: Text('No tienes grupos disponibles'));
              }
              return ListView.builder(
                itemCount: userGroups.length,
                itemBuilder: (BuildContext context, int index) {
                  final group = userGroups[index];
                  print(group);
                  return Column(
                    children: [
                      ListTile(
                        leading: ClipOval(
                          child: Image.network(
                            group['imageUrl'],
                            width: 43,
                            height: 43,
                            fit: BoxFit.cover,
                          )
                        ),
                        title: Text(group['name'] ?? '', style: TextStyle(color: Color.fromRGBO(246, 237, 220, 1))),
                        subtitle: Text(group['description'] ?? '', style: TextStyle(color: Color.fromRGBO(172, 170, 165, 1))),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            "/groupMessages",
                            arguments: {
                              'groupID': group['groupID'],
                              'name': group['asignature'],
                            }
                          );
                        },
                      ),
                      _buildCustomDivider(),
                    ],
                  );
                },
              );
            }
          },
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
}