import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import "package:flutter/material.dart";

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Recebe uma instância do Firebase Authenticator
  FirebaseAuth auth = FirebaseAuth.instance;

  // Formulário
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerLogin = TextEditingController();
  final TextEditingController _controllerSenha = TextEditingController();
  bool wrongPass = false;

  @override
  void initState() {
    // Verifica se o usuário está logado
    auth.authStateChanges().listen((User? user) {
      if (user != null) {
        Navigator.pushReplacementNamed(context, "upload");
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(48.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Image.asset(
                  "assets/logo.png",
                  height: 160,
                ),
                const Text(
                  "Can't Print",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Text(
                    "Uma forma simples de compartilhar imagens temporariamente",
                    textAlign: TextAlign.center),
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Divider(
                    color: Colors.purple,
                  ),
                ),
                TextFormField(
                  controller: _controllerLogin,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(label: Text("Usuário")),
                  validator: (value) {
                    if (value == null ||
                        value.length < 5 ||
                        !value.contains("@") ||
                        !value.contains(".")) {
                      return "Insira um e-mail válido";
                    }
                    return null;
                  },
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
                ),
                const Text(
                  "Ao entrar um e-mail que não existe, registra-se com a senha informada.",
                  style: TextStyle(fontSize: 10),
                  textAlign: TextAlign.center,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void signIn(BuildContext context) async {
    wrongPass = false;
    _formKey.currentState!.validate();

    // Aqui receberemos todas as informações do usuário caso o login/registro
    // seja um sucesso. No nosso exemplo, porém, não usamos para nada.
    // ignore: unused_local_variable
    UserCredential? userCredential;

    try {
      // Tenta autenticar o usuário com e-mail e a senha informados
      userCredential = await auth.signInWithEmailAndPassword(
        email: _controllerLogin.text,
        password: _controllerSenha.text,
      );

      toUploadScreen(context);
    } on FirebaseAuthException catch (exception) {
      // Caso a senha esteja incorreta, informa.
      if (exception.code == "wrong-password") {
        wrongPass = true;
        _formKey.currentState!.validate();
      }

      // Caso o usuário não seja encontrado
      if (exception.code == 'user-not-found') {
        showRegisterDialog(context);
      }
    }
  }

  registerUser() async {
    // Cria um usuário usando o email e a senha
    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: _controllerLogin.text,
      password: _controllerSenha.text,
    );

    // Registra ID e Email no Firestore
    await FirebaseFirestore.instance
        .collection(_controllerLogin.text)
        .doc("data")
        .set(
      {
        'uid': userCredential.user!.uid,
        "email": _controllerLogin.text,
      },
    );

    toUploadScreen(context);
  }

  void showRegisterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Deseja registrar o seguinte e-mail?"),
          content: Text(_controllerLogin.text),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancelar",
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                registerUser();
              },
              child: const Text("REGISTRAR"),
            ),
          ],
        );
      },
    );
  }

  toUploadScreen(BuildContext context) async {
    Navigator.pushReplacementNamed(context, "upload");
  }
}
