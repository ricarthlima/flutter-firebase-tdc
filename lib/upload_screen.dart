import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cant_print/list_shared_images.dart';
import 'package:uuid/uuid.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Uuid uuid = const Uuid();
  User? user;

  @override
  void initState() {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, "login");
      } else {
        setState(() {
          this.user = user;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Can't Print"),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: CircleAvatar(),
              accountEmail: Text(
                (user != null) ? user!.email! : "",
                style: const TextStyle(color: Colors.white),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text("Sair"),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          upload();
        },
        child: const Icon(Icons.add),
      ),
      body: (user != null) ? ListSharedImages(user) : Container(),
    );
  }

  void upload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Escolha uma imagem",
      type: FileType.image,
    );

    if (result != null) {
      // Gerar ID da imagem
      String imageId = uuid.v1();

      // Escolher arquivo
      File file = File(result.files.single.path!);

      // Enviar o arquivo para o Firebase Storage
      await storage.ref('uploads/' + imageId).putFile(file);

      // Associa a imagem ao usuário usando CloudFirestore
      firestore.collection(user!.uid.toString()).doc(imageId).set(
        {
          "created_at": DateTime.now().toString(),
        },
      );
    } else {
      // User canceled the picker
    }
  }
}
