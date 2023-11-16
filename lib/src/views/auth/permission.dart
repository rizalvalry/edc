import 'dart:async';

import 'package:app_dart/main.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/controllers/imei.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Permission extends StatefulWidget {
  final String responseMessage; // Tambahkan parameter responseMessage

  Permission({required this.responseMessage});

  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  late Future<String> _deviceResponse;
  Timer? _autoRefreshTimer;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    _deviceResponse = fetchData();
    _autoRefreshData(); // Memulai auto refresh data
  }

  void _autoRefreshData() {
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      refreshData();
    });
  }

  void refreshData() async {
    setState(() {
      _deviceResponse = fetchData();
    });

    try {
      String response = await _deviceResponse;

      if (response == 'Perangkat diizinkan' && _isMounted) {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              MyApp(rc: '00', responseMessage: 'Perangkat diizinkan'),
        ));
      }
    } catch (e) {
      // Tangani kesalahan jika terjadi
      print('Error during refreshData: $e');
    }

    debugPrint('Manual data refresh initiated');
  }

  @override
  void dispose() {
    super.dispose();
    _autoRefreshTimer?.cancel(); // Batalkan timer saat widget di-dispose
    _isMounted = false;
  }

  Future<String> fetchData() async {
    await BaseUrl.initialize(); // Inisialisasi BaseUrl dengan serverIpAddress
    final url = await buildDeviceAuthorizedURL();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results != null && results.isNotEmpty) {
        final rc = results[0]['rc'];
        final responseMessage = results[0]['response'];
        final kodeCabang = results[0]['kodecabang'];
        final serverIpAddress = results[0]['serveripaddress'];

        // Cek jika respons adalah "Perangkat diizinkan"
        if (responseMessage == 'Perangkat diizinkan') {
          print('============= Area Permission Diizinkan =============');
          print('rc: $rc');
          print('response: $responseMessage');
          print('kodecabang: $kodeCabang');
          print('serveripaddress: $serverIpAddress');

          // Simpan data ke SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('rc', rc);
          await prefs.setString('responseMessage', responseMessage);
          await prefs.setString('kodecabang', kodeCabang);
          await prefs.setString('serveripaddress', serverIpAddress);

          // Dapatkan data dari API
          AndroidDeviceInfo androidInfo = await DeviceInfoPlugin().androidInfo;
          String imei = androidInfo.androidId;
          final apiUrl = await BaseUrl.getUserIdByImeiUrlDirectly(imei);
          final responseApi = await http.get(Uri.parse(apiUrl));

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

          // Navigasi ke halaman MyApp
          Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (context) {
              if (mounted) {
                return MyApp(rc: '00', responseMessage: 'Perangkat diizinkan');
              }
              return Container(); // Atau widget lain yang sesuai
            },
          ));
        }

        return responseMessage;
      }
    }
    return 'No Data';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CenteredTextWithBackgroundImage(
        responseMessage: widget.responseMessage,
        refreshData:
            refreshData, // Teruskan fungsi refreshData ke CenteredTextWithBackgroundImage
      ),
    );
  }
}

class CenteredTextWithBackgroundImage extends StatelessWidget {
  final String responseMessage; // Tambahkan parameter responseMessage
  final VoidCallback refreshData; // Tambahkan parameter refreshData

  CenteredTextWithBackgroundImage({
    required this.responseMessage,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Image.asset(
          'assets/images/unauth.png',
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
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
                    responseMessage,
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
    );
  }
}
