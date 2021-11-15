import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cant_print/login_screen.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';

import 'upload_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Can't Print",
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: "login",
      routes: {
        "login": (context) => LoginScreen(),
        "upload": (context) => UploadScreen(),
      },
    );
  }
}
