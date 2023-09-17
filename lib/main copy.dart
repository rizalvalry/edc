import 'dart:convert';

import 'package:app_dart/src/config/app_theme.dart';
import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/imei.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/auth/permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'src/views/member_list_screen.dart';
import 'src/views/member_search_delegate.dart'; // Impor MemberSearchDelegateCustom dari file terpisah
import 'package:http/http.dart' as http;



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Inisialisasi Flutter
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
    // statusBarColor: AppColor.baseColor,
  ));

  final url = await buildDeviceAuthorizedURL();
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    final results = data['results'];

    if (results != null && results.isNotEmpty) {
      final rc = results[0]['rc'];
      final responseMessage = results[0]['response'];

      runApp(MyApp(rc: rc, responseMessage: responseMessage));
      // runApp(UnAuthorizedApp(responseMessage: responseMessage)); // Menjalankan UnAuthorizedApp dengan parameter responseMessage
    }
  }
}



class UnAuthorizedApp extends StatelessWidget {
  final String responseMessage; // Tambahkan parameter responseMessage

  UnAuthorizedApp({required this.responseMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Validasi',
      home: Permission(responseMessage: responseMessage),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyApp extends StatelessWidget {
  final String rc;
  final String responseMessage;

  MyApp({required this.rc, required this.responseMessage});

  @override
  Widget build(BuildContext context) {
    if (rc == '02') {
      // Perangkat belum terdaftar
      return UnAuthorizedApp(responseMessage: responseMessage,);
    } else if (rc == '00') {
      // Perangkat diizinkan
      return MaterialApp(
        title: 'Daftar Member',
        home: MemberListScreen(
          members: MemberController()
              .fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
          currentSort: 'ASC',
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    // Jika rc tidak sesuai dengan kondisi di atas, Anda dapat mengembalikan widget lain
    // atau menangani kasus yang tidak terduga sesuai kebutuhan Anda.
    return Container();
  }
}

