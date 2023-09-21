import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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

Future<void> uploadImage(String base64Image) async {
  final url = Uri.parse(
      'https://example.com/upload'); // Ganti URL sesuai dengan endpoint server Anda.

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type':
            'application/json', // Sesuaikan tipe konten dengan kebutuhan Anda.
      },
      body: jsonEncode({
        'imageData': base64Image, // Kirim data gambar dalam format base64.
      }),
    );

    if (response.statusCode == 200) {
      // Gambar berhasil diupload.
      print('Gambar berhasil diupload');
    } else {
      // Terjadi kesalahan saat mengupload gambar.
      print('Terjadi kesalahan: ${response.reasonPhrase}');
    }
  } catch (e) {
    // Tangani kesalahan jaringan atau lainnya.
    print('Terjadi kesalahan: $e');
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key? key, required this.imagePath})
      : super(key: key);

  void _handleSaveButtonPressed() async {
    final file = File(imagePath);
    if (file.existsSync()) {
      final bytes = file.readAsBytesSync();
      final base64Image = base64Encode(bytes);

      // Panggil fungsi uploadImage untuk mengirim gambar ke server.
      await uploadImage(base64Image);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Display the Picture')),
      body: Stack(
        children: [
          Image.file(File(imagePath)),
          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: _handleSaveButtonPressed,
                child: Icon(Icons.save),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
