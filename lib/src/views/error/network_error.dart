import 'package:app_dart/src/config/app_color.dart';
import 'package:flutter/material.dart';

class NetworkErrorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Error',
      debugShowCheckedModeBanner: false, // Menghilangkan debug banner
      home: Scaffold(
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Image.asset(
                  'assets/images/network-error.png', // Ganti dengan path gambar yang sesuai
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.error,
                    size: 64.0,
                    color: Colors.red,
                  ),
                  Text(
                    'No Network Connection',
                    style: TextStyle(
                      fontSize: 20.0, fontWeight: FontWeight.bold,
                      color: AppColor
                          .dangerColor, // Ubah warna teks sesuai kebutuhan
                    ),
                  ),
                  // Tambahkan widget lain atau tindakan yang diperlukan di sini
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
