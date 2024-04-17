import 'package:flutter/material.dart';
import 'package:pmsn_07/services/auth_service.dart';
import 'package:pmsn_07/util/snackbar.dart';

class SingupScreen extends StatelessWidget {
  const SingupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();
    final GlobalKey<FormState> validationForm = GlobalKey<FormState>();
    RegExp emailVal = RegExp(r'^[0-9]{8}@itcelaya\.edu\.mx$');
    RegExp passwordVal = RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,16}$');

    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

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
        if(value != null && value.isEmpty){
          return "Ingresa un correo";
        } else if(!emailVal.hasMatch(value!)){
          return "El correo no es valido";
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
        } else if(!passwordVal.hasMatch(value!)) {
          return "La contraseña debe tener:\n-8 a 16 caracteres\n-Iniciar con mayuscula\n-Contener numeros\n-Contener caracteres especiales";
        }
        return null;
      },
    );

    final btnSingup = ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color.fromRGBO(88, 104, 117, 1),
      ),
      child: const Text(
        'Registrarse',
        style: TextStyle(
          color: Colors.white,
          fontSize: 20
        ),
      ),
      onPressed: () async {
        if(!validationForm.currentState!.validate()){
          Future(() => showDialog(
            context: context, 
            builder: (BuildContext context) => const AlertDialog(
              title: Text("No se pudo registrar"),
              content: Text("Algunos datos son incorrectos, por favor verificalos antes de continuar"),
          ))
          );
        } else{
          var result = await auth.createAcount(emailController.text, passwordController.text);
          if(result == 1){
            showSnackBar(context, 'Contraseña demasiad debil');
          } else if(result == 2){
            showSnackBar(context, 'Este email ya se encuentra registrado');
          } else if(result != null){
            Navigator.pushNamed(context, "/dash");
          }
          // Future.delayed(
          //   new Duration(milliseconds: 2000),
          //   (){
          //     Navigator.pushNamed(context, "/dash").then((value){});
          //   }
          // );
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
            child: ListView(
              children: [
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
                            'Registro',
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
                            )
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    GestureDetector(
                      onTap: () {
                        // Navegar a otra pantalla al hacer clic en el texto "Registrate"
                      },
                      child: const Text(
                        '¿No tienes cuenta? Registrate',
                        style: TextStyle(
                          color: Colors.white, // Cambiar el color del texto clickeable
                        ),
                      ),
                    ),
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