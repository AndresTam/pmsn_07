import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_07/services/storage_service.dart';
import 'package:pmsn_07/util/select_file.dart';
import 'package:pmsn_07/util/snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/services/firestore_messages.dart';
import 'package:video_player/video_player.dart';

class GroupsMessageScreen extends StatefulWidget {
  const GroupsMessageScreen({super.key});

  @override
  State<GroupsMessageScreen> createState() => _GroupsMessageScreenState();
}

class _GroupsMessageScreenState extends State<GroupsMessageScreen> {
  final String auth = FirebaseAuth.instance.currentUser!.uid;
  final FirestoreMessage _firestoreMessage = FirestoreMessage();
  final FirestoreUser _firestoreUser = FirestoreUser();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  VideoPlayerController? _videoPlayerController;
  final Map<String, VideoPlayerController> _videoControllers = {};
  late Stream<List<Map<String, dynamic>>> _messagesStream;
  late Widget messageWidget;
  File? imageToUpload;

  @override
  void initState() {
    super.initState();
  }

   @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _videoPlayerController?.dispose();
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _sendMessage(
      Map<String, dynamic>? args, String type, String messageText) {
    if (messageText.isNotEmpty) {
      DateTime now = DateTime.now();
      String formattedDateTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      _firestoreMessage.createMessage(args?['groupID'], messageText, auth, formattedDateTime, type);
      _messageController.clear();
      FocusScope.of(context).unfocus();
      _scrollToBottom(0);
      setState(() {});
    }
  }
  
  void _scrollToBottom(int length) {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    }
  }

  void _playVideo(String videoUrl) async {
    VideoPlayerController? controller = _videoControllers[videoUrl];
    if (controller != null) {
      if (!controller.value.isInitialized) {
        await controller.initialize();
      }
      await controller.play();
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
          ),
        ),
      ));
    }
  }

  Future<Map<String, dynamic>> _getUserData(String userID) async {
    Map<String, dynamic>? userData = await _firestoreUser.getUser(userID);
    return userData ?? {};
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic>? args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _messagesStream = _firestoreMessage.getMessagesStream(args?['groupID']);

    return Scaffold(
      appBar: AppBar(
        title: Text(args?['name'] ?? 'HOLA'),
        backgroundColor: const Color.fromRGBO(88, 104, 117, 1),
      ),
      body: Container(
        color: const Color.fromRGBO(88, 104, 117, 1),
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _messagesStream,
                builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final messagesList = snapshot.data ?? [];
                    messagesList.sort((a, b) => b['date'].compareTo(a['date']));
                    return ListView.builder(
                      controller: _scrollController,
                      reverse: true, // Mostrar los mensajes más recientes al final
                      itemCount: messagesList.length,
                      itemBuilder: (BuildContext context, int index) {
                        final message = messagesList[index];
                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getUserData(message['sender']),
                          builder: (context, userSnapshot) {
                            if (userSnapshot.connectionState == ConnectionState.waiting) {
                              return const ListTile(
                                title: Text('Loading...'),
                              );
                            }
                            if (userSnapshot.hasData) {
                              final userData = userSnapshot.data!;
                              final bool isMe = message['sender'] == auth;
                              return _buildMessage(message, userData, isMe);
                            }
                            return const ListTile(
                              title: Text('User Not Found'),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            _buildInputField(context, args),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, Map<String, dynamic> userData, bool isMe) {
    DateTime dateTime = DateTime.parse(message['date']);
    DateFormat dateFormat = DateFormat.Hm();
    String formattedTime = dateFormat.format(dateTime);
    
    if (message['type'] == 'text') {
      // Mensaje de texto
      messageWidget = Text(
        message['message'],
        style: const TextStyle(fontSize: 16),
      );
    } else if (message['type'] == 'image') {
      messageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(
            10.0), // Ajusta el radio según lo que necesites
        child: Image.network(
          message['message'],
          width: 200, // Ancho de la imagen
          height: 200, // Alto de la imagen
          fit: BoxFit
              .cover, // Ajusta la forma en que la imagen se ajusta al contenedor
        ),
      );
    } else if (message['type'] == 'video') {
      messageWidget = ClipRRect(
        borderRadius: BorderRadius.circular(10.0),
        child: _buildVideoMessage(message['message'], isMe),
      );
    }
    final messageContent = Container(
      decoration: BoxDecoration(
        color: isMe ? Colors.lightBlueAccent : Colors.grey[300],
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (!isMe)
            Text(
              userData['name'] ?? 'Unknown',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          const SizedBox(height: 4),
          messageWidget,
          const SizedBox(height: 4),
          Text(
            formattedTime, // Replace with actual timestamp
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Wrap(
          alignment: isMe ? WrapAlignment.end : WrapAlignment.start,
          children: [
            if (!isMe)
              ClipOval(
                child: Image.network(
                  userData['imgProfile'],
                  width: 20,
                  height: 20,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(width: 8), // Espacio entre la imagen y el mensaje
            IntrinsicWidth(child: messageContent),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoMessage(String videoUrl, bool isMe) {
    VideoPlayerController videoController =
        VideoPlayerController.networkUrl(Uri.parse(videoUrl));
    _videoControllers[videoUrl] = videoController;

    return GestureDetector(
      onTap: () {
        _playVideo(videoUrl);
      },
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(videoController),
            const Icon(Icons.play_arrow, size: 50), // Icono de reproducción
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(BuildContext context, Map<String, dynamic>? args) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
          8.0, 8.0, 8.0, 12.0), // Ajusta el margen inferior
      decoration: const BoxDecoration(
        border:
            Border(top: BorderSide(color: Color.fromRGBO(118, 130, 141, 1))),
        color: Color.fromRGBO(88, 104, 117, 1),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Escribe un mensaje...',
                  hintStyle:
                      const TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20.0)),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.add,
                color: Color.fromRGBO(246, 237, 220, 1),
              ),
              onPressed: () {
                _showBottomSheet(context, args);
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.send,
                color: Color.fromRGBO(246, 237, 220, 1),
              ),
              onPressed: () =>{
                 _sendMessage(args, 'text', _messageController.text.trim()),
              }
            ),
          ],
        ),
      ),
    );
  }

  void _showBottomSheet(BuildContext context, Map<String, dynamic>? args) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          color: const Color.fromRGBO(189, 214, 210, 1),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ListTile(
                leading: const Icon(Icons.image,
                    color: Color.fromRGBO(35, 42, 48, 1)),
                title: const Text(
                  'Enviar imagen',
                  style: TextStyle(color: Color.fromRGBO(35, 42, 48, 1)),
                ),
                onTap: () async {
                  final image = await getImagenByGallery();
                  setState(() {
                    if (image != null) {
                      imageToUpload = File(image.path);
                    }
                  });
                  Navigator.pop(context);
                  _showImageDialog(context, args, 'image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera,
                    color: Color.fromRGBO(35, 42, 48, 1)),
                title: const Text(
                  'Tomar foto',
                  style: TextStyle(color: Color.fromRGBO(35, 42, 48, 1)),
                ),
                onTap: () async {
                  final image = await getImagenByCamera();
                  setState(() {
                    if (image != null) {
                      imageToUpload = File(image.path);
                    }
                  });
                  Navigator.pop(context);
                  _showImageDialog(context, args, 'image');
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_collection,
                    color: Color.fromRGBO(35, 42, 48, 1)),
                title: const Text(
                  'Enviar Video',
                  style: TextStyle(color: Color.fromRGBO(35, 42, 48, 1)),
                ),
                onTap: () async {
                  final image = await getVideoByGallery();
                  setState(() {
                    if (image != null) {
                      imageToUpload = File(image.path);
                    }
                  });
                  Navigator.pop(context);
                  _showImageDialog(context, args, 'video');
                },
              ),
              ListTile(
                leading: const Icon(Icons.video_call_rounded,
                    color: Color.fromRGBO(35, 42, 48, 1)),
                title: const Text(
                  'Tomar Video',
                  style: TextStyle(color: Color.fromRGBO(35, 42, 48, 1)),
                ),
                onTap: () async {
                  final image = await getVideoByCamera();
                  setState(() {
                    if (image != null) {
                      imageToUpload = File(image.path);
                    }
                  });
                  Navigator.pop(context);
                  _showImageDialog(context, args, 'video');
                },
              ),
            ],
          ),
        );
      },
    );
  }
  Future<void> _showImageDialog(
      BuildContext context, Map<String, dynamic>? args, String type) async {
    if (imageToUpload != null && type == 'image') {
      return showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Imagen'),
            content: Image.file(imageToUpload!),
            backgroundColor: const Color.fromRGBO(189, 214, 210, 1),
            actions: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cerrar'),
                  ),
                  TextButton(
                    onPressed: () async {
                      showSnackBar(context, 'Enviando Archivo');
                      final String fileName =
                          imageToUpload!.path.split("/").last;
                      final uploadedImage = await uploadChatImage(
                          imageToUpload!, 'chats', args?['groupID'], fileName);
                      if (uploadedImage.isNotEmpty) {
                        _sendMessage(args, 'image', uploadedImage);
                        showSnackBar(context, 'Archivo Enviado');
                        Navigator.of(context).pop();
                      } else {
                        showSnackBar(context, 'Ocurrio algún fallo');
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Enviar'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    } else if (imageToUpload != null && type == 'video') {
      _videoPlayerController = VideoPlayerController.file(imageToUpload!)
        ..initialize().then((_) {
          setState(() {});
          _videoPlayerController!.play;
        });
      if (_videoPlayerController != null) {
        return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Video'),
              content: AspectRatio(
                aspectRatio: _videoPlayerController!.value.aspectRatio,
                child: VideoPlayer(_videoPlayerController!),
              ),
              backgroundColor: const Color.fromRGBO(189, 214, 210, 1),
              actions: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Cerrar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        showSnackBar(context, 'Enviando Archivo');
                        final String fileName =
                            imageToUpload!.path.split("/").last;
                        final uploadedImage = await uploadChatVideo(
                            imageToUpload!,
                            'chats',
                            args?['groupID'],
                            fileName);
                        if (uploadedImage.isNotEmpty) {
                          _sendMessage(args, 'video', uploadedImage);
                          showSnackBar(context, 'Archivo Enviado');
                          Navigator.of(context).pop();
                        } else {
                          showSnackBar(context, 'Ocurrio algún fallo');
                          Navigator.of(context).pop();
                        }
                      },
                      child: const Text('Enviar'),
                    ),
                  ],
                ),
              ],
            );
          }
        );
      }
    }
  }
}