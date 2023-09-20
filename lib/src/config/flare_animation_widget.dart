// import 'package:flare_flutter/flare_actor.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/material.dart';
import 'package:snackbar/snackbar.dart';

class FlareAnimationWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String? alertMessage;

  FlareAnimationWidget({required this.scaffoldKey, this.alertMessage});

  @override
  _FlareAnimationWidgetState createState() => _FlareAnimationWidgetState();
}

class _FlareAnimationWidgetState extends State<FlareAnimationWidget> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // Setelah 2 detik, gambar akan dihapus dari tampilan
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        _isVisible = false;
        if (widget.alertMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Text(widget.alertMessage!),
                  duration: Duration(seconds: 2),
                ),
              )
              .closed
              .then((_) {
            // Kembali ke halaman sebelumnya setelah Snackbar ditutup
            Navigator.of(context).pop();
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _isVisible
              ? Image.asset(
                  'assets/images/success-two.gif',
                  width: 200, // Sesuaikan dengan ukuran yang Anda inginkan
                  height: 200, // Sesuaikan dengan ukuran yang Anda inginkan
                )
              : Container(), // Container kosong jika gambar tidak terlihat
        ],
      ),
    );
  }
}
