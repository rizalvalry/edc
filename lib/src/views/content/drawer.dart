// ignore_for_file: unused_local_variable, library_prefixes, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, deprecated_member_use

import 'dart:typed_data';

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:app_dart/src/views/topup/log_topup.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

String getGreeting() {
  final currentTime = DateTime.now();
  final hour = currentTime.hour;

  if (hour >= 0 && hour < 9) {
    return 'Selamat Pagi';
  } else if (hour >= 9 && hour < 12) {
    return 'Selamat Siang';
  } else if (hour >= 12 && hour < 17) {
    return 'Selamat Sore';
  } else {
    return 'Selamat Malam';
  }
}

class CustomDrawer extends StatelessWidget {
  String getImagePathBasedOnTime() {
    final currentTime = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(currentTime);

    if (formattedTime.compareTo('00:00') >= 0 &&
        formattedTime.compareTo('09:00') < 0) {
      return 'assets/images/morning.png'; // Path gambar pagi
    } else if (formattedTime.compareTo('09:00') >= 0 &&
        formattedTime.compareTo('12:00') < 0) {
      return 'assets/images/afternoon.png'; // Path gambar siang
    } else if (formattedTime.compareTo('12:00') >= 0 &&
        formattedTime.compareTo('17:00') < 0) {
      return 'assets/images/evening.png'; // Path gambar sore
    } else {
      return 'assets/images/night.png'; // Path gambar malam
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: AppColor.baseColor,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PT. AVA ABADI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    getGreeting(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 10),
                  ClipOval(
                    child: Image.asset(
                      getImagePathBasedOnTime(), // Menggunakan variabel untuk path gambar
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ),
            ),
          ),
          InkWell(
            onTap: () async {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LogTopUpPage()));
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: AppColor
                    .darkOrange, // Ganti warna latar belakang sesuai keinginan Anda
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 2,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundImage: AssetImage(
                        'assets/images/topup.png'), // Ganti dengan gambar profil yang sesuai
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LOG Top Up',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: AppColor.baseColor,
                  ),
                ],
              ),
            ),
          )

          // ListTile(
          //   title: Text('Item 2'),
          //   onTap: () {
          //     // Tambahkan logika untuk item kedua di sini
          //   },
          // ),
          // Tambahkan lebih banyak item menu jika diperlukan
        ],
      ),
    );
  }
}
