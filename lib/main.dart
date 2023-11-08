// ignore_for_file: unused_import

import 'dart:convert';
// import 'package:app_dart/src/config/app_theme.dart';
// import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/controllers/imei.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/auth/permission.dart';
import 'package:app_dart/src/views/error/network_error.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:path/path.dart';
import 'src/views/member/member_list_screen.dart';
// import 'src/views/member_search_delegate.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith());

  try {
    await BaseUrl.initialize();

    final url = await buildDeviceAuthorizedURL();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results != null && results.isNotEmpty) {
        // Cetak semua nilai dari results
        final rc = results[0]['rc'];
        final responseMessage = results[0]['response'];
        final kodeCabang = results[0]['kodecabang'];
        final serverIpAddress = results[0]['serveripaddress'];
        // final UUID = results[0]['UUID'];

        print('rc: $rc');
        print('response: $responseMessage');
        print('kodecabang: $kodeCabang');
        print('serveripaddress: $serverIpAddress');
        // print('UUID: $UUID');

        // Menyimpan data ke shared_preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('rc', rc);
        await prefs.setString('responseMessage', responseMessage);
        await prefs.setString('kodecabang', kodeCabang);
        await prefs.setString('serveripaddress', serverIpAddress);
        // await prefs.setString('UUID', UUID);

        // Inisialisasi BaseUrl dengan serverIpAddress

        runApp(MyApp(rc: rc, responseMessage: responseMessage));

        if (rc == '02') {
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;

          String imei = androidInfo.brand;
          String model = androidInfo.androidId;
          sendRequestToLocalhostAPI(imei, model, rc);
        } else if (rc == '00') {
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
          String imei = androidInfo.androidId;
          print(imei);

          final baseUrl = BaseUrl();
          String apiUrl = baseUrl.getImeiSecondAuth(imei);

          var responseApi = await http.get(Uri.parse(apiUrl));

          if (responseApi.statusCode == 200) {
            final data = json.decode(responseApi.body);
            final resultsApi = data['results'];
            print(resultsApi);
            if (resultsApi != null && resultsApi.isNotEmpty) {
              final userid = resultsApi[0]['userid'];
              final loginname = resultsApi[0]['loginname'];
              final branchid = resultsApi[0]['branchid'];

              // Simpan data ke SharedPreferences
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('userid', userid.toString());
              await prefs.setString('loginname', loginname);
              await prefs.setString('branchid', branchid);

              print(
                  '============= Area Admin Diberi Otorisasi Penuh =============');
              print(userid);
              print(loginname);
              print(branchid);
            }
          }
        }
      }
    } else {
      runApp(NetworkErrorPage());
    }
  } catch (e) {
    // Handle NoNetworkException (network is not available)
    if (e is NoNetworkException) {
      runApp(NetworkErrorPage());
    }
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
