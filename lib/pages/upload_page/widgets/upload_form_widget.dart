import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class UploadFormWidget extends StatefulWidget {
  final FilePickerResult result;
  final User user;

  const UploadFormWidget(this.result, {Key? key, required this.user})
      : super(key: key);

  @override
  _UploadFormWidgetState createState() => _UploadFormWidgetState();
}

class _UploadFormWidgetState extends State<UploadFormWidget> {
  bool isUniqueView = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailsController = TextEditingController();
  final TextEditingController _ttlController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Form(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(0, 16, 0, 8),
                child: Text(
                  "Enviar imagem",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(
                color: Colors.purple,
              ),
              Image.file(File(widget.result.files.single.path!), height: 150),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  label: Text("Nome da Imagem:"),
                  helperText: "Opcional",
                ),
              ),
              TextFormField(
                controller: _emailsController,
                decoration: const InputDecoration(
                  label: Text("E-mails para compartilhar:"),
                  helperText: "Opcional - Separado por vírgula",
                ),
              ),
              TextFormField(
                controller: _ttlController,
                decoration: const InputDecoration(
                  label: Text("Tempo para expiração"),
                  suffixText: "Segundos",
                ),
                keyboardType: TextInputType.number,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                      value: isUniqueView,
                      onChanged: (value) {
                        setState(() {
                          isUniqueView = !isUniqueView;
                        });
                      }),
                  const Text("Visualização única"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: ElevatedButton(
                  onPressed: () => upload(context),
                  child: const Text("Enviar"),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void upload(BuildContext context) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Gerar ID da imagem
    String imageId = const Uuid().v1();

    // Escolher arquivo
    File file = File(widget.result.files.single.path!);

    // Enviar o arquivo para o Firebase Storage
    await storage.ref('uploads/' + imageId).putFile(file);

    // Associa a imagem ao usuário usando CloudFirestore
    firestore.collection(widget.user.email!).doc(imageId).set(
      {
        "name": _nameController.text,
        "ttl": _ttlController.text,
        "isUniqueView": isUniqueView,
        "created_at": DateTime.now().toString(),
      },
    );

    // Compartilha a imagem com os usuários válidos usando o CloudFirestore
    _emailsController.text.split(",").forEach(
      (email) {
        firestore
            .collection(email)
            .doc("shared")
            .collection("shared")
            .doc(imageId)
            .set(
          {
            "ownerEmail": widget.user.email!,
            "imageId": imageId,
          },
        );
      },
    );

    // Fecha o modal
    Navigator.pop(context);
  }
}
