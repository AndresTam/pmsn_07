import 'package:flutter/material.dart';
import 'package:pmsn_07/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pmsn_07/screens/splash_screen.dart';
import 'package:pmsn_07/screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        "/dash": (BuildContext context) => const DashboardScreen(),
      },
    );
  }
}