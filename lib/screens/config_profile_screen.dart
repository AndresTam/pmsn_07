import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/services/storage_service.dart';
import 'package:pmsn_07/util/select_file.dart';
import 'package:pmsn_07/util/snackbar.dart';

class ConfigProfileScreen extends StatefulWidget {
  const ConfigProfileScreen({super.key});

  @override
  State<ConfigProfileScreen> createState() => _ConfigProfileScreenState();
}

class _ConfigProfileScreenState extends State<ConfigProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GlobalKey<FormState> validationForm = GlobalKey<FormState>();
  final FirestoreUser firestoreUser = FirestoreUser();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController careerController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController sentenceController = TextEditingController();

  File? imageToUpload;
  dynamic userID;

  @override
  Widget build(BuildContext context) {
    // Verificar si los argumentos no son nulos y acceder a los datos
    Map<String, dynamic>? args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      String name = args["name"];
      String? career = args["career"];
      String position = args["position"];
      String sentence = args["sentence"];
      String email = args["email"];
      String imgProfile = args["imgProfile"];
      dynamic userID = args["userID"];
      // Usa los datos recuperados según sea necesario
    }
    TextEditingController nameController =
        TextEditingController(text: args?["name"]);
    TextEditingController careerController =
        TextEditingController(text: args?["career"]);
    TextEditingController positionController =
        TextEditingController(text: args?["position"]);
    TextEditingController sentenceController =
        TextEditingController(text: args?["sentence"]);

    final txtName = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius:
            BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Nombre',

            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder
                .none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.person,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Ingresa un nombre";
            }
            return null;
          },
        ),
      ),
    );

    final txtCareer = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius:
            BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: careerController,
          decoration: const InputDecoration(
            hintText: 'Carrera',
            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder
                .none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.article,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Ingresa tu carrera";
            }
            return null;
          },
        ),
      ),
    );

    final txtPosition = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius:
            BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: positionController,
          decoration: const InputDecoration(
            hintText: 'Puesto',
            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder
                .none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.school,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Ingresa tu carrera";
            }
            return null;
          },
        ),
      ),
    );

    final txtSentence = Container(
      decoration: BoxDecoration(
        color: const Color.fromRGBO(165, 200, 202, 1),
        borderRadius:
            BorderRadius.circular(10.0), // Ajusta el radio según tu preferencia
        border: Border.all(
          color: const Color.fromRGBO(165, 200, 202, 1), // Color del borde
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TextFormField(
          controller: sentenceController,
          decoration: const InputDecoration(
            hintText: 'Estado',
            hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
            border: InputBorder
                .none, // Oculta el borde por defecto del TextFormField
            icon: Icon(
              Icons.mode_outlined,
              color: Color.fromRGBO(246, 237, 220, 1),
            ),
          ),
          validator: (value) {
            if (value != null && value.isEmpty) {
              return "Ingresa tu carrera";
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
          if (image != null) {
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

    final btnSave = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(165, 200, 202, 1),
      ),
      child: const Text(
        'Guardar',
        style: TextStyle(color: Color.fromRGBO(246, 237, 220, 1), fontSize: 20),
      ),
      onPressed: () async {
        if (!validationForm.currentState!.validate()) {
          Future(
            () => showDialog(
              context: context,
              builder: (BuildContext context) => const AlertDialog(
                title: Text("No se pudo guardar la información"),
                content: Text("Debes llenar todos los campos"),
              ),
            ),
          );
        } else {
          print(
              "ID: ${args?['userID']}\nname: ${nameController.text} \ncareer: ${careerController.text} \nposition: ${positionController.text} \n sentence: ${sentenceController.text}\n uploadedImage: ${imageToUpload.toString()}\n ${args?["imgProfile"]}");
          if (imageToUpload != null) {
            showSnackBar(context, 'Guardando Datos');
            final uploadedImage = await uploadProfileImage(
                imageToUpload!, 'imgProfile', 'profileImage');

            firestoreUser.updateProfile(
              args?['userID'],
              nameController.text,
              careerController.text,
              positionController.text,
              sentenceController.text,
              uploadedImage,
            );
          } else {
            firestoreUser.updateProfile(
              args?['userID'],
              nameController.text,
              careerController.text,
              positionController.text,
              sentenceController.text,
              args?['imgProfile'],
            );
          }

          showSnackBar(context, 'Datos Guardados');
          Navigator.pushNamed(context, "/dash");
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
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      const Text(
                        'Configuracion del perfil',
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
                                    : Image(
                                        image: NetworkImage(
                                          args?['imgProfile'],
                                        ),
                                        width: 150,
                                        height: 150,
                                      ),
                              ),
                              const SizedBox(height: 20.0),
                              txtName,
                              const SizedBox(height: 20.0),
                              txtCareer,
                              const SizedBox(height: 20.0),
                              txtPosition,
                              const SizedBox(height: 20.0),
                              txtSentence,
                              const SizedBox(height: 20.0),
                              btnGallery,
                              const SizedBox(height: 20.0),
                              btnSave,
                            ],
                          )),
                    ],
                  ),
                  const SizedBox(height: 20.0),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
