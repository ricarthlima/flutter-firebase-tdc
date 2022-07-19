import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import 'widgets/list_images_widget.dart';
import 'widgets/upload_form_widget.dart';

class UploadPage extends StatefulWidget {
  const UploadPage({Key? key}) : super(key: key);

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  User? user;

  bool isShowingShared = false;

  @override
  void initState() {
    checkUserState();
    super.initState();
  }

  // Verifica se há desconexão do usuário
  void checkUserState() {
    auth.authStateChanges().listen((User? user) {
      if (user == null) {
        Navigator.pushReplacementNamed(context, "login");
      } else {
        setState(() {
          this.user = user;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          (isShowingShared) ? "Imagens compartilhadas" : "Minhas imagens",
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            UserAccountsDrawerHeader(
              accountName: const CircleAvatar(),
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
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "btn1",
            onPressed: () {
              setState(() {
                isShowingShared = !isShowingShared;
              });
            },
            mini: true,
            child: Icon(
              (!isShowingShared) ? Icons.folder_shared : Icons.folder,
            ),
          ),
          FloatingActionButton(
            heroTag: "btn2",
            onPressed: () {
              openModalToUpload();
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      body: (user != null)
          ? ListImagesWidget(user, isShowingShared)
          : const CircularProgressIndicator(),
    );
  }

  void openModalToUpload() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      dialogTitle: "Escolha uma imagem",
      type: FileType.image,
    );

    if (result != null) {
      showMaterialModalBottomSheet(
        context: context,
        expand: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        builder: (BuildContext _context) {
          return UploadFormWidget(
            result,
            user: user!,
          );
        },
      );
    }
  }
}
