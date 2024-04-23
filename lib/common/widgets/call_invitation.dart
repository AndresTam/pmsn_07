import 'package:flutter/material.dart';
import 'package:pmsn_07/common/static.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallInvitationPage extends StatelessWidget {
  const CallInvitationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return ZegoUIKitPrebuiltCall(
        appID: Statics.appID,
        appSign: Statics.appSign,
        userID: args?["userID1"],
        userName: args?['username'],
        callID: args?["callID"],
        config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall());
  }
}

// void onUserLogin() {
//   /// 1.2.1. initialized ZegoUIKitPrebuiltCallInvitationService
//   /// when app's user is logged in or re-logged in
//   /// We recommend calling this method as soon as the user logs in to your app.
//   ZegoUIKitPrebuiltCallInvitationService().init(
//     appID: Statics.appID,
//       appSign: Statics.appSign,
//       userID: args?["userID1"],
//       userName: args?['username'],
//     plugins: [ZegoUIKitSignalingPlugin()],
//   );
// }
