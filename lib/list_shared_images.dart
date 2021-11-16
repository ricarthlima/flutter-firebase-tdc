import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class ListSharedImages extends StatefulWidget {
  User? user;
  ListSharedImages(this.user, {Key? key}) : super(key: key);

  @override
  State<ListSharedImages> createState() => _ListSharedImagesState();
}

class _ListSharedImagesState extends State<ListSharedImages> {
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<String> listImageNames = [];

  @override
  void initState() {
    firestore.collection(widget.user!.uid).snapshots().listen((snapshot) {
      setState(() {
        listImageNames = [];
        for (DocumentSnapshot doc in snapshot.docs) {
          listImageNames.add(doc.id);
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: listImageNames.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(listImageNames[index]),
        );
      },
    );
  }
}
