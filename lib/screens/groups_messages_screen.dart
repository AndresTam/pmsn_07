import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class GroupsMessageScreen extends StatefulWidget {
  GroupsMessageScreen({Key? key}) : super(key: key);

  @override
  State<GroupsMessageScreen> createState() => _GroupsMessageScreenState();
}

class _GroupsMessageScreenState extends State<GroupsMessageScreen> {
  final String auth = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}