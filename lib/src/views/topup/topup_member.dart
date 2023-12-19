// ignore_for_file: must_be_immutable, unnecessary_import, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_final_fields

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/app_text.dart';
import 'package:app_dart/src/views/topup/nfc_session.dart';
import 'package:app_dart/src/views/topup/tag_read.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopUpMemberScreen extends StatefulWidget {
  String memberId;
  String kodeCabang;
  String memberName;

  TopUpMemberScreen(
      {required this.memberId,
      required this.kodeCabang,
      required this.memberName});

  @override
  _TopUpMemberScreenState createState() => _TopUpMemberScreenState();
}

class _TopUpMemberScreenState extends State<TopUpMemberScreen> {
  TextEditingController _nominalController = TextEditingController();
  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  String kodeCabang = '';
  String actionType = 'topup';
  String amount = '';
  // String memberName = '';

  @override
  void initState() {
    super.initState();
    _getKodeCabang();
    // _nominalController.addListener(_onNominalChanged);
  }

  // Metode untuk mengambil kodecabang dari shared_preferences
  _getKodeCabang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.kodeCabang = prefs.getString('kodecabang') ??
          ''; // Menggunakan nilai default jika data tidak ditemukan
    });
  }

  @override
  void dispose() {
    // _nominalController.removeListener(_onNominalChanged);
    // _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: AppColor.baseColor,
        title: Align(
          alignment: Alignment.centerLeft,
          child: AppText(
            'Top-Up Member - Cabang ${widget.kodeCabang}',
            style: TextStyle(color: AppColor.darkOrange),
          ),
        ),
        centerTitle: false, // Mengatur judul ke kiri
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Card(
            elevation: 4.0,
            margin: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/topup-images.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(
                        0.2), // Sesuaikan tingkat keburaman di sini
                    BlendMode.dstATop,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Text(
                        'ID ${widget.memberId} (${widget.memberName})',
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueGrey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      'Jumlah Nominal : ${_currencyFormatter.format(double.tryParse(_nominalController.text) ?? 0)}',
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    TextField(
                      controller: _nominalController,
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {});
                      },
                      decoration: const InputDecoration(
                        focusColor: Colors.blue,
                        border: OutlineInputBorder(),
                        hintText: 'Masukkan jumlah nominal',
                      ),
                    ),
                    const SizedBox(height: 22.0),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          amount = _nominalController.text;
                        });

                        startSession(
                          context: context,
                          handleTag: (tag) async {
                            final tagReadModel = TagReadModel(
                              kodeCabang: widget.kodeCabang,
                              memberId: widget.memberId,
                              actionType: actionType,
                              amount: amount,
                            );
                            return await tagReadModel.handleTag(tag, context);
                          },
                        );
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                            AppColor.baseColor),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        elevation: MaterialStateProperty.all<double>(8.0),
                        shadowColor:
                            MaterialStateProperty.all<Color>(Colors.black),
                        minimumSize: MaterialStateProperty.all<Size>(
                          const Size(200.0, 50.0),
                        ),
                      ),
                      child: const Text(
                        'Top-Up Sekarang',
                        style:
                            TextStyle(fontSize: 18, color: AppColor.darkOrange),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
