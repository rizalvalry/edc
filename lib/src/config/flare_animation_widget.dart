import 'package:flutter/material.dart';

class FlareAnimationWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String? alertMessage;
  final String? actionType;
  final BuildContext previousContext;

  const FlareAnimationWidget({
    super.key,
    required this.scaffoldKey,
    this.alertMessage,
    this.actionType, // Tambahkan parameter actionType
    required this.previousContext,
  });

  @override
  // ignore: library_private_types_in_public_api
  _FlareAnimationWidgetState createState() => _FlareAnimationWidgetState();
}

class _FlareAnimationWidgetState extends State<FlareAnimationWidget> {
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    // if (widget.actionType == "backVoid") {
    //   // Navigator.of(widget.previousContext).pop();
    //   Navigator.of(context).pop();
    // }
    // Setelah 2 detik, gambar akan dihapus dari tampilan
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isVisible = false;

        if (widget.alertMessage != null) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
                SnackBar(
                  content: Text(widget.alertMessage!),
                  duration: const Duration(seconds: 2),
                ),
              )
              .closed
              .then((_) {
            // Validasi actionType
            if (widget.actionType == "resetpin") {
              // Jika actionType adalah "resetpin", lakukan Navigator.pop
              Navigator.of(context).pop();
            }
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
