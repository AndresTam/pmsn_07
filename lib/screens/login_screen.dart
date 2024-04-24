import 'package:flutter/material.dart';
import 'package:pmsn_07/common/static.dart';
import 'package:pmsn_07/services/auth_service.dart';
import 'package:pmsn_07/services/firestore_user.dart';
import 'package:pmsn_07/util/snackbar.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

Future<void> createEngine() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Get your AppID and AppSign from ZEGOCLOUD Console
  //[My Projects -> AppID] : https://console.zegocloud.com/project
  await ZegoExpressEngine.createEngineWithProfile(
    ZegoEngineProfile(
      Statics.appID,
      ZegoScenario.Default,
      appSign: Statics.appSign,
    ),
  );
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final GlobalKey<FormState> validationForm = GlobalKey<FormState>();

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final FirestoreUser _firestoreUser = FirestoreUser();
    final txtEmail = TextFormField(
      controller: emailController,
      decoration: const InputDecoration(
        hintText: 'Correo',
        hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
        icon: Icon(
          Icons.email,
          color: Color.fromRGBO(246, 237, 220, 1),
        ),
      ),
      validator: (value) {
        if (value != null && value.isEmpty) {
          return "Ingresa un correo";
        }
        return null;
      },
    );

    final txtPassword = TextFormField(
      controller: passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        hintText: 'Contraseña',
        hintStyle: TextStyle(color: Color.fromRGBO(246, 237, 220, 1)),
        icon: Icon(
          Icons.lock,
          color: Color.fromRGBO(246, 237, 220, 1),
        ),
      ),
      validator: (value) {
        if (value != null && value.isEmpty) {
          return 'Ingresa una contraseña';
        }
        return null;
      },
    );

    final btnSingup = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(88, 104, 117, 1),
      ),
      child: const Text(
        'Iniciar Sesión',
        style: TextStyle(color: Colors.white, fontSize: 20),
      ),
      onPressed: () async {
        if (!validationForm.currentState!.validate()) {
          Future(
            () => showDialog(
              context: context,
              builder: (BuildContext context) => const AlertDialog(
                title: Text("No se pudo iniciar sesión"),
                content: Text("Debes llenar todos los campos"),
              ),
            ),
          );
        } else {
          var result = await auth.singinEmailAndPassword(
              emailController.text, passwordController.text);
          if (result == 1 || result == 2) {
            showSnackBar(context, 'Correo o contraseña incorrectos');
          } else if (result != null) {
            final userID =
                await _firestoreUser.getUserIdFromEmail(emailController.text);
            print("userID: ${userID}");

            await createEngine();

            Navigator.pushNamed(context, "/dash");
          }
        }
      },
    );

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromRGBO(246, 237, 220, 1),
              Color.fromRGBO(88, 104, 117, 1),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('images/logo.png'),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15), // Efecto glass
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Text(
                          'Iniciar Sesión',
                          style: TextStyle(
                            color: Color.fromRGBO(88, 104, 117, 1),
                            fontSize: 30,
                          ),
                        ),
                        Form(
                            key: validationForm,
                            child: Column(
                              children: [
                                txtEmail,
                                const SizedBox(height: 20.0),
                                txtPassword,
                                const SizedBox(height: 20.0),
                                btnSingup,
                              ],
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  GestureDetector(
                    child: const Text(
                      '¿No tienes cuenta? Registrate aquí.',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, "/singup");
                    },
                  ),
                ],
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
