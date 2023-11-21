// ignore_for_file: unnecessary_null_comparison, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:app_dart/src/views/settlement/print_settlement.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ignore: use_key_in_widget_constructors
class SettlementScreen extends StatefulWidget {
  @override
  _SettlementScreenState createState() => _SettlementScreenState();
}

class _SettlementScreenState extends State<SettlementScreen> {
  late DateTime _currentTime;
  late Timer _timer; // Deklarasikan timer di sini
  bool isLoading = false;

  Future<void> rePrintSettlement(String settlementNumber) async {
    final baseUrl = BaseUrl();
    final settlementUrl = baseUrl.settlementAction();

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('userid') ?? '';

    try {
      final response = await http.post(
        Uri.parse(settlementUrl),
        body: {
          'reff_number': userid,
          'settlement_no': settlementNumber,
        },
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Permintaan berhasil
        final responseData = response.body;
        print('Response Data: $responseData');
        final responseJson = json.decode(responseData);

        final settlementNo = responseJson['SettlementNo'];

        if (settlementNo == "00") {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data Tidak Ditemukan!'),
            ),
          );
        } else {
          final transactions = responseJson['transactions'][0] as List<dynamic>;
          _currentTime = DateTime.now();

          final transactionsList = transactions.cast<Map<String, dynamic>>();

          Future.delayed(const Duration(seconds: 2), () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PrintSettlement(
                  title: 'Re Print Settlement',
                  date: _currentTime.toString(),
                  transactions: transactionsList,
                  settlementNo: settlementNo,
                ),
              ),
            );
          });
        }
      } else {
        print('Request failed with status: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement request failed!'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred while sending the request.'),
        ),
      );
    }
  }

  void _showHistoryDialog() {
    TextEditingController settlementNumberController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColor.baseColor,
          contentTextStyle: TextStyle(color: Colors.white),
          title: Text('History', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextFormField(
                style: const TextStyle(color: Colors.white),
                controller: settlementNumberController,
                decoration: InputDecoration(
                  hintText: 'Masukan Nomor Settlement',
                  hintStyle: TextStyle(
                      color:
                          Colors.white), // Atur warna teks hint menjadi putih
                  fillColor: Colors.white,
                  focusColor: Colors.white,
                  prefixIconColor: Colors.white,
                  labelStyle: TextStyle(
                      color:
                          Colors.white), // Atur warna teks label menjadi putih
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Atur warna border ketika field tidak aktif menjadi putih
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                        color: Colors
                            .white), // Atur warna border ketika field aktif menjadi putih
                  ),

                  // Atur style untuk teks yang dimasukkan/diketik
                  // Jika Anda ingin teks yang dimasukkan menjadi putih, atur warna teksnya menjadi putih
                  // Anda juga dapat mengatur properti lain sesuai kebutuhan, seperti fontSize, fontWeight, dsb.
                  // Contoh:
                  // style: TextStyle(color: Colors.white),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  String settlementNumber = settlementNumberController.text;
                  rePrintSettlement(
                      settlementNumber); // Memanggil fungsi rePrintSettlement
                  Navigator.of(context).pop(); // Tutup dialog
                },
                child: Text('Re-Print Settlement'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    // Membuat timer yang akan memperbarui waktu setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    final baseUrl = BaseUrl();
    final settlementUrl = baseUrl.settlementAction();

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('userid') ?? '';

    print(userid);
    try {
      final response = await http.post(
        Uri.parse(settlementUrl),
        body: {'reff_number': userid, 'settlement_no': '0'},
      );

      print(response.body);

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Permintaan berhasil
        final responseData = response.body;
        // ignore: avoid_print
        print('Response Data: $responseData');
        // Parsing respons JSON
        final responseJson = json.decode(responseData);

        // Mengambil nomor penyelesaian
        final settlementNo = responseJson['SettlementNo'];

        if (settlementNo == "00") {
          // Jika SettlementNo adalah "00", tampilkan pesan "Sudah Pernah di Settlement"
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content:
                  Text('Tidak Ada History atau Sudah Pernah di Settlement'),
            ),
          );
        } else {
          // Jika SettlementNo bukan "00", arahkan ke halaman PrintSettlement
          final transactions = responseJson['transactions'][0] as List<dynamic>;
          _currentTime = DateTime.now();

          // Konversi data transaksi menjadi List<Map<String, dynamic>>
          final transactionsList = transactions.cast<Map<String, dynamic>>();

          // Arahkan otomatis ke halaman PrintSettlement dengan mengirimkan data yang dibutuhkan
          Future.delayed(const Duration(seconds: 2), () {
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
        // ignore: avoid_print
        print('Request failed with status: ${response.statusCode}');

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settlement request failed!'),
          ),
        );
      }
    } catch (error) {
      print('Error: $error');

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
        // ignore: prefer_const_constructors
        title: Text(
          'Settlement Submit',
          style: const TextStyle(color: AppColor.darkOrange),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppColor.darkOrange),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MemberListScreen(
                members: MemberController()
                    .fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                currentSort: 'ASC',
              ),
            ));
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.history,
              color: AppColor.darkOrange,
            ),
            onPressed: () {
              _showHistoryDialog();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/settlement.png', // Ganti dengan path gambar latar belakang Anda
            fit: BoxFit
                .cover, // Sesuaikan sesuai kebutuhan (cover, contain, dll.)
            width: double.infinity,
            height: double.infinity,
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Card(
                  color: Colors.white10,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  shadowColor: AppColor.baseColor,
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 64,
                          color: AppColor.darkOrange,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          _currentTime != null
                              ? '${_currentTime.hour}:${_currentTime.minute}:${_currentTime.second}'
                              : 'Loading...',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (!isLoading) {
                      sendSettlementRequest();
                    }
                  },
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(AppColor.baseColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    elevation: MaterialStateProperty.all<double>(8.0),
                    shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size(200.0, 50.0),
                    ),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator(
                          color: AppColor.darkOrange,
                        )
                      : const Text(
                          'Settle Now',
                          style: TextStyle(
                              fontSize: 20, color: AppColor.darkOrange),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
