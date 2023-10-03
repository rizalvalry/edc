import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

// ignore: use_key_in_widget_constructors
class CameraPermissionScreen extends StatefulWidget {
  @override
  // ignore: library_private_types_in_public_api
  _CameraPermissionScreenState createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen>
    with WidgetsBindingObserver {
  late CameraController _cameraController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Tambahkan observer

    // Memindahkan inisialisasi kamera ke dalam fungsi initCamera
    initCamera();
  }

  // Fungsi untuk inisialisasi kamera
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      initCamera(); // Inisialisasi ulang kamera saat aplikasi dilanjutkan dari background
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    WidgetsBinding.instance.removeObserver(this); // Hapus observer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera Standby'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Lanjutkan ke Photo',
              style: TextStyle(fontSize: 16.0),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(
                //     builder: (context) => ImageUpload(
                //       // cameraController: _cameraController,
                //       // firstCamera: firstCamera,
                //     ),
                //   ),
                // );
              },
              child: const Text(
                'Take Picture',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
