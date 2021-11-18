import 'package:flutter/material.dart';
import 'package:flutter_cant_print/models/image_firestore_model.dart';

class ImageWidget extends StatelessWidget {
  final ImageFirestoreModel imageFirestore;

  const ImageWidget({Key? key, required this.imageFirestore}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, "image", arguments: imageFirestore.id);
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        width: 96,
        child: Stack(
          children: [
            Image.network(
              imageFirestore.urlInStorage!,
              width: 96,
            ),
            Container(
              height: 96,
              width: 96,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    Color.fromARGB(25, 50, 50, 50),
                    Color.fromARGB(75, 50, 50, 50),
                    Color.fromARGB(150, 50, 50, 50),
                    Color.fromARGB(255, 50, 50, 50)
                  ],
                  begin: Alignment.center,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: 96,
                child: Text(
                  imageFirestore.createdAt!,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
