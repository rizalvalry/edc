import 'dart:convert';
import 'package:app_dart/src/config/app_theme.dart';
import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/imei.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/auth/permission.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'src/views/member_list_screen.dart';
import 'src/views/member_search_delegate.dart';
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

      if (rc == '02') {
        AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

        String imei = androidInfo.brand;
        String model = androidInfo.androidId;
        _sendRequestToLocalhostAPI(imei, model, rc);
      }
    }
  }
}

void _sendRequestToLocalhostAPI(String imei, String model, String rc) async {
  try {
    final url = Uri.parse(
        'http://192.168.18.106/api/?phoneimei=$imei&model=$model&rc=$rc');
    print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
    } else {
      print('Gagal mengambil data dari URL http://192.168.18.106/api/');
    }
  } catch (e) {
    print('Terjadi kesalahan: $e');
  }
}

class UnAuthorizedApp extends StatelessWidget {
  final String responseMessage;

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
      return UnAuthorizedApp(
        responseMessage: responseMessage,
      );
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

    return Container();
  }
}
