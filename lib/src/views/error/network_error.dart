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
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Image.asset(
                'assets/images/network-error.png', // Ganti dengan path gambar yang sesuai
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
            Center(
              child: Card(
                elevation: 5.0,
                color: Colors.black.withOpacity(0.7),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 20,
                    children: [
                      Text(
                        'No Network Connection',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 255, 51, 0),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
