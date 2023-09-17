import 'dart:async';

import 'package:app_dart/main.dart';
import 'package:app_dart/src/controllers/imei.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:onesignal_flutter/onesignal_flutter.dart';

class Permission extends StatefulWidget {
  final String responseMessage; // Tambahkan parameter responseMessage

  Permission({required this.responseMessage});

  @override
  _PermissionState createState() => _PermissionState();
}

class _PermissionState extends State<Permission> {
  late Future<String> _deviceResponse;
  Timer? _autoRefreshTimer;

  @override
  void initState() {
    super.initState();
    _deviceResponse = fetchData();
    _autoRefreshData(); // Memulai auto refresh data
  }

  void _autoRefreshData() {
    _autoRefreshTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      refreshData();
    });
  }

  void refreshData() {
    setState(() {
      _deviceResponse = fetchData();
    });
    _deviceResponse.then((response) {
      if (response == 'Perangkat diizinkan' &&
          widget.responseMessage != 'Perangkat diizinkan') {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) =>
              MyApp(rc: '00', responseMessage: 'Perangkat diizinkan'),
        ));
      }
    });
    debugPrint('Manual data refresh initiated');
  }

  @override
  void dispose() {
    super.dispose();
    _autoRefreshTimer?.cancel(); // Batalkan timer saat widget di-dispose
  }

  Future<String> fetchData() async {
    final url = await buildDeviceAuthorizedURL();
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final results = data['results'];

      if (results != null && results.isNotEmpty) {
        final rc = results[0]['rc'];
        final responseMessage = results[0]['response'];
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

// Future<void> sendOneSignal() async {
//     const url =
//         'http://192.168.18.103/wartelsus/edc/device_authorized?phoneimei=8de4562ad29e605d&device=JP-02&model=JP-02&api=8.1.0&devicetype=2';

//     // Buat permintaan HTTP ke URL
//     final response = await http.get(Uri.parse(url));

//     if (response.statusCode == 200) {
//       final message = response.body; // Pesan dari respon HTTP

//       // Kirim notifikasi ke OneSignal
//       final notification = OSCreateNotification(
//         playerIds: [
//           'ddf01a2d-4995-4ae5-8e35-9221a73b40af'
//         ], // Ganti dengan Player ID yang sesuai
//         content: message, // Isi notifikasi dengan pesan dari URL
//         heading:
//             'Ada Sebuah Permintaan Perangkat', // Ganti dengan judul yang sesuai
//       );

//       final result = await OneSignal.shared.postNotification(notification);

//       if (result['success'] == true) {
//         // Notifikasi berhasil dikirim
//         print('Notifikasi berhasil dikirim.');
//       } else {
//         // Notifikasi gagal dikirim
//         print('Notifikasi gagal dikirim.');
//       }
//     } else {
//       // Gagal mengambil data dari URL
//       print('Gagal mengambil data dari URL.');
//     }
//   }

  CenteredTextWithBackgroundImage({
    required this.responseMessage,
    required this.refreshData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(50),
      child: Stack(
        children: <Widget>[
          Image.asset(
            'assets/images/unauth.png',
            fit: BoxFit.cover,
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
                    // ElevatedButton(
                    //   onPressed:
                    //       sendOneSignal, // Panggil refreshData saat tombol ditekan
                    //   child: Text('Refresh'),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
