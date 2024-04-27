import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/services/storage_service.dart';
import 'package:pmsn_07/util/select_file.dart';
import 'package:pmsn_07/util/snackbar.dart';
import 'package:uuid/uuid.dart';

class GroupInfoScreen extends StatefulWidget {
  const GroupInfoScreen({super.key});

  @override
  State<GroupInfoScreen> createState() => _GroupInfoScreenState();
}

class _GroupInfoScreenState extends State<GroupInfoScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> validationForm = GlobalKey<FormState>();
  final FirestoreUser firestoreUser = FirestoreUser();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController asignatureController = TextEditingController();
  final TextEditingController descriptionController= TextEditingController();
  final TextEditingController sentenceController = TextEditingController();

  File? imageToUpload;

  @override
  Widget build(BuildContext context) {

    final txtName = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius: BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Nombre del grupo',
            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder.none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.person,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if(value != null && value.isEmpty){
              return "Ingresa un nombre";
            }
            return null;
          },
        ),
      ),
    );

    final txtAsignature = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius: BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: asignatureController,
          decoration: const InputDecoration(
            hintText: 'Materia',
            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder.none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.school,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if(value != null){
              return "Nombre de la materia";
            }
            return null;
          },
        ),
      ),
    );

    final txtDescription = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius: BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: descriptionController,
          decoration: const InputDecoration(
            hintText: 'Descripción',
            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder.none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.article,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if(value != null && value.isEmpty){
              return "Descripción del grupo";
            }
            return null;
          },
        ),
      ),
    );

    final btnGallery = ElevatedButton(
      onPressed: () async {
        final image = await getImagenByGallery();
        setState(() {
          if(image != null){
            imageToUpload = File(image.path);
          }
        });
      },
      style: ElevatedButton.styleFrom(fixedSize: const Size(400, 50)),
      child: const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(
            width: 20,
          ),
          Text('Elige una foto de la galería')
        ],
      ),
    );

    final btnCamera = ElevatedButton(
      onPressed: () async {
        final image = await getImagenByCamera();
        setState(() {
          if(image != null){
            imageToUpload = File(image.path);
          }
        });
      },
      style: ElevatedButton.styleFrom(fixedSize: const Size(400, 50)),
      child: const Row(
        children: [
          Icon(Icons.image_outlined),
          SizedBox(
            width: 20,
          ),
          Text('Tomar fotografía')
        ],
      ),
    );

    final btnSave = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(165, 200, 202, 1),
      ),
      child: const Text(
        'Siguiente',
        style: TextStyle(
          color: Color.fromRGBO(246, 237, 220, 1),
          fontSize: 20
        ),
      ),
      onPressed: () async {
        if(imageToUpload != null && nameController.text != '' && asignatureController.text != '' && descriptionController.text != ''){
          var uuid = const Uuid();
          String groupId = uuid.v4();
          final uploadedImage = await uploadGroupImage(imageToUpload!, 'groups', groupId, 'groupImgProfile');
          if(uploadedImage != ''){
            Navigator.pushNamed(
              context,
              "/groupCreation",
              arguments: {
                'groupId': groupId,
                'name': nameController.text,
                'asignature': asignatureController.text,
                'description': descriptionController.text,
                'image': uploadedImage,
                'edit': false,
                'participantList': [] as List<String>,
              }
            );
          }
        } else {
          showSnackBar(context, 'No puedes dejar campos vacios');
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          color: Color.fromRGBO(88, 104, 117, 1),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Información',
                          style: TextStyle(
                            color: Color.fromRGBO(246, 237, 220, 1),
                            fontSize: 30,
                          ),
                        ),
                        Form(
                          key: validationForm,
                          child: Column(
                            children: [                           
                              const SizedBox(height: 20.0),
                              ClipOval(
                                child: imageToUpload != null
                                  ? Image.file(
                                      imageToUpload!,
                                      width: 150,
                                      height: 150,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'images/avatar.png',
                                      width: 150,
                                    ),
                              ),
                              const SizedBox(height: 20.0),
                              txtName,
                              const SizedBox(height: 20.0),
                              txtAsignature,
                              const SizedBox(height: 20.0),
                              txtDescription,
                              const SizedBox(height: 20.0),
                              btnGallery,
                              const SizedBox(height: 20.0),
                              btnCamera,
                              const SizedBox(height: 20.0),
                              btnSave,
                            ],
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                  ],
                ),
              ]
            ),
          ),
        ),
      ),
    );
  }
}