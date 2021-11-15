import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController _controllerLogin = TextEditingController();
  TextEditingController _controllerSenha = TextEditingController();

  bool wrongPass = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    auth.userChanges().listen((User? user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "upload");
      }
    });

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(64.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _controllerLogin,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(label: Text("Usuário")),
              ),
              TextFormField(
                controller: _controllerSenha,
                keyboardType: TextInputType.visiblePassword,
                decoration: const InputDecoration(label: Text("Senha")),
                obscureText: true,
                validator: (value) {
                  if (wrongPass) {
                    return "Senha incorreta :(";
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 32,
              ),
              ElevatedButton(
                onPressed: () => signIn(context),
                child: const Text("Entrar ou Registrar-se"),
              )
            ],
          ),
        ),
      ),
    );
  }

  void signIn(BuildContext context) async {
    wrongPass = false;

    UserCredential? userCredential;

    try {
      userCredential = await auth.signInWithEmailAndPassword(
        email: _controllerLogin.text,
        password: _controllerSenha.text,
      );

      toUploadScreen(userCredential, context);
    } on FirebaseAuthException catch (exception) {
      if (exception.code == 'user-not-found') {
        userCredential = await auth.createUserWithEmailAndPassword(
          email: _controllerLogin.text,
          password: _controllerSenha.text,
        );
        toUploadScreen(userCredential, context);
      }

      if (exception.code == "wrong-password") {
        wrongPass = true;
        _formKey.currentState!.validate();
      }
    }
  }

  toUploadScreen(UserCredential? userCredential, BuildContext context) async {
    if (userCredential != null) {
      Navigator.pushReplacementNamed(context, "upload");
    }
  }
}
