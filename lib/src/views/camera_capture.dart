import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    MaterialApp(
      theme: ThemeData.dark(),
      home: TakePictureScreen(
        cameraController: CameraController(
          firstCamera,
          ResolutionPreset.medium,
        ),
        firstCamera: firstCamera, // Tambahkan firstCamera sebagai argumen
      ),
    ),
  );
}

class TakePictureScreen extends StatelessWidget {
  final CameraController? cameraController;
  final CameraDescription firstCamera;

  const TakePictureScreen({
    Key? key,
    required this.cameraController,
    required this.firstCamera, // Tambahkan parameter firstCamera
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final initializeControllerFuture = (cameraController ??
            CameraController(firstCamera, ResolutionPreset.medium))
        .initialize();

    return WillPopScope(
      onWillPop: () async {
        cameraController?.dispose(); // Menghentikan dan me-"dispose" kamera
        return true; // Izinkan pengguna untuk kembali
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Take a picture')),
        body: FutureBuilder<void>(
          future: initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return CameraPreview(cameraController!);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            try {
              final image = await (cameraController ??
                      CameraController(firstCamera, ResolutionPreset.medium))
                  .takePicture();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(
                    imagePath: image.path,
                  ),
                ),
              );
            } catch (e) {
              print(e);
            }
          },
          child: const Icon(Icons.camera_alt),
        ),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Image.file(File(imagePath)),
    );
  }
}
