import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String imageId = ModalRoute.of(context)!.settings.arguments as String;
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: StfImagePage(
          imageId: imageId,
        ),
      ),
    );
  }
}

class StfImagePage extends StatefulWidget {
  final String imageId;
  const StfImagePage({Key? key, required this.imageId}) : super(key: key);

  @override
  _StfImagePageState createState() => _StfImagePageState();
}

class _StfImagePageState extends State<StfImagePage> {
  String? imageUrl;

  @override
  void initState() {
    getImageFromStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return (imageUrl == null)
        ? const Center(child: CircularProgressIndicator())
        : Center(child: Image.network(imageUrl!));
  }

  /// Pega uma imagem do Storage para ser mostrada na tela
  void getImageFromStorage() {
    FirebaseStorage storage = FirebaseStorage.instance;

    storage.ref("uploads/" + widget.imageId).getDownloadURL().then(
      (urlDownload) {
        setState(
          () {
            imageUrl = urlDownload;
          },
        );
      },
    );
  }
}
