import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/views/settlement/print_settlement.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SettlementScreen extends StatefulWidget {
  @override
  _SettlementScreenState createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  late DateTime _currentTime;
  late Timer _timer; // Deklarasikan timer di sini
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    // Membuat timer yang akan memperbarui waktu setiap detik
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          // Perubahan state yang ingin Anda lakukan
        });
      }
    });

    // Menginisialisasi waktu awal
    _currentTime = DateTime.now();
  }

  @override
  void dispose() {
    _timer.cancel(); // Batalkan timer di sini
    super.dispose();
  }

  Future<void> sendSettlementRequest() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('userid') ?? '';
    try {
      final response = await http.post(
        Uri.parse('http://192.168.18.103/wartelsus/edc/POSSettlementEdc'),
        body: {'reff_number': userid},
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Permintaan berhasil
        final responseData = response.body;
        print('Response Data: $responseData');
        // Parsing respons JSON
        final responseJson = json.decode(responseData);

        // Mengambil nomor penyelesaian
        final settlementNo = responseJson['SettlementNo'];

        if (settlementNo == "00") {
          // Jika SettlementNo adalah "00", tampilkan pesan "Sudah Pernah di Settlement"
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sudah Pernah di Settlement'),
            ),
          );
        } else {
          // Jika SettlementNo bukan "00", arahkan ke halaman PrintSettlement
          final transactions = responseJson['transactions'][0] as List<dynamic>;
          _currentTime = DateTime.now();

          // Konversi data transaksi menjadi List<Map<String, dynamic>>
          final transactionsList = transactions.cast<Map<String, dynamic>>();

          // Arahkan otomatis ke halaman PrintSettlement dengan mengirimkan data yang dibutuhkan
          Future.delayed(Duration(seconds: 2), () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PrintSettlement(
                  title: 'Settlement Print',
                  date: _currentTime.toString(),
                  transactions: transactionsList,
                  settlementNo: settlementNo,
                ),
              ),
            );
          });
        }
      } else {
        // Permintaan gagal
        print('Request failed with status: ${response.statusCode}');
        // Tampilkan Snackbar dengan pesan kesalahan jika diperlukan
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Settlement request failed!'),
          ),
        );
      }
    } catch (error) {
      // Tangani kesalahan jika terjadi
      print('Error: $error');
      // Tampilkan Snackbar dengan pesan kesalahan jika diperlukan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while sending the request.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.baseColor,
        title: Text(
          'Settlement Submit',
          style: TextStyle(color: AppColor.darkOrange),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Card(
              color: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(12.0), // Mengatur sudut melengkung
              ),
              shadowColor: AppColor.lightGrey,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 64,
                      color: AppColor.darkOrange,
                    ),
                    SizedBox(height: 20),
                    Text(
                      _currentTime != null
                          ? '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}'
                          : 'Loading...',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (!isLoading) {
                  sendSettlementRequest(); // Panggil fungsi untuk HIT POST
                }
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(AppColor
                    .baseColor), // Ganti dengan warna latar belakang yang Anda inginkan
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Atur radius sesuai keinginan
                  ),
                ),
                elevation: MaterialStateProperty.all<double>(
                    8.0), // Atur tinggi shadow sesuai keinginan
                shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                minimumSize: MaterialStateProperty.all<Size>(
                  Size(200.0,
                      50.0), // Sesuaikan ukuran sesuai keinginan (lebar x tinggi)
                ),
              ),
              child: isLoading
                  ? CircularProgressIndicator(
                      // Tampilkan loading indicator saat isLoading adalah true
                      color: AppColor.darkOrange,
                    )
                  : Text(
                      'Settle Now',
                      style:
                          TextStyle(fontSize: 20, color: AppColor.darkOrange),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
