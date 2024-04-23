// import 'dart:convert';

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:pmsn_07/common/app_colors.dart';
// import 'package:pmsn_07/common/app_notifications.dart';
// import 'package:pmsn_07/common/call_model.dart';
// import 'package:pmsn_07/common/notification_model.dart';
// import 'package:pmsn_07/common/user_controller.dart';
// import 'package:pmsn_07/common/user_model.dart';
// import 'package:pmsn_07/common/video_call_screen.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class ConfigCall {
//   static Future<void> initialVideoCall({
//     required String call,
//     required UserModel receiver,
//     required bool video,
//   }) async {
//     final callDocument = await FirebaseFirestore.instance
//         .collection('Calls')
//         .doc(receiver.id)
//         .get();

//     if (!callDocument.exists) {
//       await addCallDocs(callid: call, receiver: receiver, video: video);
//       ZegoUIKitPrebuiltCallController controller =
//           ZegoUIKitPrebuiltCallController();

//       Get.to(
//         () => VideoCallPage(
//           callID: call,
//           controller: controller,
//           otherid: receiver.id!,
//           video: video,
//         ),
//       );
//     } else {
//       Get.defaultDialog(
//         title: '${getName(receiver)} is on another call!',
//         middleText: 'Please try calling this user later.',
//         titlePadding: const EdgeInsets.only(top: 15, bottom: 10),
//         textCancel: 'Okay',
//         buttonColor: AppColors.primary,
//         cancelTextColor: AppColors.primary,
//       );
//     }
//   }

//   static Future<void> addCallDocs({
//     required String callid,
//     required UserModel receiver,
//     required bool video,
//   }) async {
//     final CallModel call = CallModel(
//       id: Get.find<UserController>().userid,
//       callid: callid,
//       created: DateTime.now(),
//       receiverImage: receiver.profile!,
//       receiverName: getName(receiver),
//       receiverid: receiver.id,
//       senderImage: Get.find<UserController>().current.profile,
//       senderName: getName(Get.find<UserController>().current),
//       senderid: Get.find<UserController>().userid,
//       isMade: true,
//       video: video,
//     );
//     await FirebaseFirestore.instance
//         .collection("Calls")
//         .doc(Get.find<UserController>().userid)
//         .set(call.toMap());
//     call.id = receiver.id;
//     call.isMade = false;
//     await callRef.doc(receiver.id).set(call.toMap());
//     await sendNotifications(call, receiver);
//   }

//   static Future<void> sendNotifications(
//     CallModel call,
//     UserModel receiver,
//   ) async {
//     final String token = receiver
//         .token; // Supongamos que el token está disponible en el objeto UserModel

//     final String admin = await getAdminToken();
//     final String url =
//         'https://fcm.googleapis.com/v1/projects/{PROJECT ID}/messages:send';
//     final Uri uri = Uri.parse(url);
//     final Map<String, String> headers = {
//       'content-type': 'application/json',
//       'Authorization': 'Bearer $admin',
//     };

//     final AppNotifications notification = AppNotifications(
//       title: 'New Call',
//       subtitle: 'You have a new call from ${call.senderName}',
//       sender: call.senderid,
//       type: NotificationType.call,
//     );

//     final response = await http.post(
//       uri,
//       headers: headers,
//       body: jsonEncode({
//         "message": {
//           "token": token,
//           "notification": {
//             "body": notification.subtitle,
//             "title": notification.title
//           },
//           "data": {
//             "click_action": "FLUTTER_NOTIFICATION_CLICK",
//             "id": "1",
//             "status": "done",
//             "sound": 'default',
//             'userid': notification.sender,
//             'peerid': call.receiverid,
//             'title': notification.title,
//             'body': notification.subtitle,
//             'type': notification.type.toString(),
//           }
//         },
//       }),
//     );

//     debugPrint(response.body);
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
