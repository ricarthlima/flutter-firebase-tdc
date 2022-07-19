import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'firebase_options.dart';
import 'pages/image_page/image_page.dart';
import 'pages/login_page/login_page.dart';
import 'pages/upload_page/upload_page.dart';

void main() async {
  // Necessário quando usa-se uma "main()" assíncrona
  WidgetsFlutterBinding.ensureInitialized();

  //Linha responsável por proibir printscreens
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);

  // Inicializa o app Firebase (usando as informações no google-services.json)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Can't Print",
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: "login",
      routes: {
        "login": (context) => const LoginPage(),
        "upload": (context) => const UploadPage(),
        "image": (context) => const ImagePage(),
      },
    );
  }
}
