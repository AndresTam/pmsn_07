import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_07/common/widgets/call_invitation.dart';
import 'package:pmsn_07/firebase_options.dart';
import 'package:pmsn_07/screens/config_profile_screen.dart';
import 'package:pmsn_07/screens/dashboard_screen.dart';
import 'package:pmsn_07/screens/login_screen.dart';
import 'package:pmsn_07/screens/messages_screen.dart';
import 'package:pmsn_07/screens/profile_registration.dart';
import 'package:pmsn_07/screens/settings_screeen.dart';
import 'package:pmsn_07/screens/singup_screen.dart';
import 'package:pmsn_07/screens/splash_screen.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  /// 1.1.2: set navigator key to ZegoUIKitPrebuiltCallInvitationService
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(navigatorKey);

  /// call the useSystemCallingUI
  ZegoUIKit().initLog().then((value) {
    ZegoUIKitPrebuiltCallInvitationService().useSystemCallingUI(
      [ZegoUIKitSignalingPlugin()],
    );

    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
      routes: {
        "/dash": (BuildContext context) => const DashboardScreen(),
        "/login": (BuildContext context) => const LoginScreen(),
        "/singup": (BuildContext context) => const SingupScreen(),
        "/profileRegistration": (BuildContext context) =>
            const ProfileRegistration(),
        "/messages": (BuildContext context) => const MessagesScreen(),
        "/settings": (BuildContext context) => const SettingsScreen(),
        "/profileConfig": (BuildContext context) => const ConfigProfileScreen(),
        "/call": (BuildContext context) => const CallInvitationPage(),
      },
    );
  }
}
