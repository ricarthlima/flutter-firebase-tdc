import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import '../../../models/image_firestore_model.dart';
import 'image_widget.dart';

// ignore: must_be_immutable
class ListImagesWidget extends StatefulWidget {
  User? user;
  ListImagesWidget(this.user, {Key? key}) : super(key: key);

  @override
  State<ListImagesWidget> createState() => _ListImagesWidgetState();
}

class _ListImagesWidgetState extends State<ListImagesWidget> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<ImageFirestoreModel> listImageFirestore = [];
  List<ImageFirestoreModel> listSharedImageFirestore = [];

  bool isShowingShared = false;

  @override
  void initState() {
    setupListeners();
    super.initState();
  }

  setupListeners() {
    // Listener para Imagens Proprias
    firestore.collection(widget.user!.email!).snapshots().listen((snapshot) {
      listImageFirestore = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        if (doc.id != "data" && doc.id != "shared") {
          storage.ref("uploads/" + doc.id).getDownloadURL().then((urlDownload) {
            setState(() {
              listImageFirestore.add(
                ImageFirestoreModel(
                  id: doc.id,
                  createdAt: doc.get("created_at"),
                  urlInStorage: urlDownload,
                ),
              );
            });
          });
        }
      }
    });

    // Listener para Imagens Compartilhadas
    firestore
        .collection(widget.user!.email!)
        .doc("shared")
        .collection("shared")
        .snapshots()
        .listen((snapshot) {
      listSharedImageFirestore = [];

      for (DocumentSnapshot doc in snapshot.docs) {
        storage
            .ref("uploads/" + doc.get("imageId"))
            .getDownloadURL()
            .then((urlDownload) {
          setState(() {
            listSharedImageFirestore.add(
              ImageFirestoreModel(
                id: doc.id,
                createdAt: doc.get("ownerEmail"),
                urlInStorage: urlDownload,
              ),
            );
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              setState(() {
                isShowingShared = !isShowingShared;
              });
            },
            child: Text(
              (!isShowingShared)
                  ? "Mostrar compartilhadas comigo"
                  : "Mostrar minhas imagens",
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              children: [
                for (ImageFirestoreModel imageFirestore in (!isShowingShared)
                    ? listImageFirestore
                    : listSharedImageFirestore)
                  ImageWidget(imageFirestore: imageFirestore)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
