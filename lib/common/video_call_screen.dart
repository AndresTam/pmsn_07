// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:pmsn_07/common/notification_model.dart';
// import 'package:pmsn_07/common/static.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
// import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

// class VideoCallPage extends StatefulWidget {
//   const VideoCallPage({
//     Key? key,
//     required this.callID,
//     required this.controller,
//     required this.otherid,
//     required this.video,
//   }) : super(key: key);
//   final String callID, otherid;
//   final ZegoUIKitPrebuiltCallController controller;
//   final bool video;

//   @override
//   State<VideoCallPage> createState() => _VideoCallPageState();
// }

// class _VideoCallPageState extends State<VideoCallPage> {
//   bool joined = false;

//   void showSnackbar(String error) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(error), // Cambio aquí
//         action: SnackBarAction(
//           label: 'Open Settings',
//           onPressed: () async {
//             openAppSettings();
//           },
//         ),
//       ),
//     );
//   }

//   Future<void> getPermissions() async {
//     // Cambio aquí
//     final Map<Permission, PermissionStatus> permissions = await [
//       Permission.microphone,
//       Permission.camera,
//     ].request();
//     final PermissionStatus microphone = permissions[Permission.microphone]!;
//     final PermissionStatus camera = permissions[Permission.camera]!;
//     if (microphone == PermissionStatus.denied &&
//         camera == PermissionStatus.denied) {
//       showSnackbar(
//         'Application needs access to camera and microphone for calls',
//       );
//     } else if (microphone == PermissionStatus.denied) {
//       showSnackbar(
//         'Application needs access to microphone for calls',
//       );
//     } else if (camera == PermissionStatus.denied) {
//       showSnackbar(
//         'Application needs access to camera for calls',
//       );
//     } else {
//       widget.controller.hangUp(context);
//     }
//     if (mounted) setState(() {});
//   }

//   @override
//   void initState() {
//     super.initState();
//     getPermissions();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return StreamBuilder(
//       stream: callRef.where('callid', isEqualTo: widget.callID).snapshots(),
//       builder: (context, AsyncSnapshot snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const CustomProgressBar();
//         } else if (snapshot.hasData == false ||
//             snapshot.data.docs.isEmpty ||
//             snapshot.hasError) {
//           widget.controller.hangUp(context);
//           return Container();
//         }
//         return ZegoUIKitPrebuiltCall(
//           callID: widget.callID,
//           appID: Statics.appID,
//           appSign: Statics.appSign,
//           plugins: [ZegoUIKitSignalingPlugin()],
//           userID: Get.find<UserController>().userid,
//           userName: getName(Get.find<UserController>().current),
//           config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
//             ..turnOnMicrophoneWhenJoining = true
//             ..turnOnCameraWhenJoining = widget.video
//             ..useSpeakerWhenJoining = true,
//           onDispose: () {},
//           events: ZegoUIKitPrebuiltCallEvents(
//             onCallEnd: (event, action) {
//               ZegoServices.removeCallDocs(
//                 widget.otherid,
//                 widget.callID,
//                 joined ? 1 : 2,
//                 true,
//               ); // to delete documents when a user ends the call.
//             },
//             audioVideo: ZegoUIKitPrebuiltCallAudioVideoEvents(),
//             user: ZegoUIKitPrebuiltCallUserEvents(
//               onEnter: (value) {
//                 Get.log('enter:$value');
//                 joined = true;
//                 Get.log('joined: $joined');
//               },
//               onLeave: (value) {
//                 Get.log('leave:$value');
//               },
//             ),
//           ),
//         );
//       },
//     );
//   }

//   static Future sendNotification(
//     String token,
//     String receiverid,
//     AppNotifications notification,
//   ) async {
//     try {
//       String admin = await getAdminToken();
//       String url =
//           'https://fcm.googleapis.com/v1/projects/{PROJECT ID}/messages:send';
//       Uri uri = Uri.parse(url);
//       var headers = {
//         'content-type': 'application/json',
//         'Authorization': 'Bearer $admin'
//       };
//       final response = await http.post(
//         uri,
//         headers: headers,
//         body: jsonEncode({
//           "message": {
//             "token": token,
//             "notification": {
//               "body": notification.subtitle,
//               "title": notification.title
//             },
//             "data": {
//               "click_action": "FLUTTER_NOTIFICATION_CLICK",
//               "id": "1",
//               "status": "done",
//               "sound": 'default',
//               'userid': notification.sender,
//               'peerid': receiverid,
//               'title': notification.title,
//               'body': notification.subtitle,
//               'type': notification.type.toString(),
//             }
//           },
//         }),
//       );
//       debugPrint(response.body);
//     } catch (e, trace) {
//       Get.log('Error: $e');
//       Get.log('Stack trace: $trace');
//     }
//   }

//   static Future<String> getAdminToken() async {
//     return await FirebaseFirestore.instance
//         .collection('admin')
//         .doc('aKvZCfeXTzOrCxHKcRl6')
//         .get()
//         .then((value) {
//       if (value.data() != null) {
//         return value.get('access_token');
//       } else {
//         return '';
//       }
//     });
//   }
// }
