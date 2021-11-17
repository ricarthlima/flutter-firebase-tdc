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

  @override
  void initState() {
    setupListener();
    super.initState();
  }

  setupListener() {
    firestore.collection(widget.user!.uid).snapshots().listen((snapshot) {
      listImageFirestore = [];

      for (DocumentSnapshot doc in snapshot.docs) {
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
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Wrap(
          children: [
            for (ImageFirestoreModel imageFirestore in listImageFirestore)
              ImageWidget(imageFirestore: imageFirestore)
          ],
        ),
      ),
    );
  }
}
