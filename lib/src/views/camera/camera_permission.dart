import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:app_dart/src/views/camera_capture.dart';

class CameraPermissionScreen extends StatefulWidget {
  @override
  _CameraPermissionScreenState createState() => _CameraPermissionScreenState();
}

class _CameraPermissionScreenState extends State<CameraPermissionScreen>
    with WidgetsBindingObserver {
  late CameraController _cameraController;
  bool _cameraInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this); // Tambahkan observer

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
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        initCamera(); // Inisialisasi ulang kamera saat aplikasi dilanjutkan dari background
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    WidgetsBinding.instance!.removeObserver(this); // Hapus observer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Camera Standby'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Lanjutkan ke Photo',
              style: TextStyle(fontSize: 16.0),
            ),
            ElevatedButton(
              onPressed: () {
                final firstCamera = _cameraController.description;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TakePictureScreen(
                      cameraController: _cameraController,
                      firstCamera: firstCamera,
                    ),
                  ),
                );
              },
              child: Text(
                'Take Picture',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
