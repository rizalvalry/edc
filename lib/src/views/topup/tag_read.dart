import 'dart:io';
import 'dart:typed_data';
import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/config/my_utils.dart';
import 'package:app_dart/src/views/form_row.dart';
import 'package:app_dart/src/views/ndef_record.dart';
import 'package:app_dart/src/views/topup/nfc_session.dart';
import 'package:app_dart/src/views/topup/print_invoice.dart';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:convert';

void main() {
  DateTime now = DateTime.now();
  String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
  print(formattedDate);
}

class TagReadModel with ChangeNotifier {
  TagReadModel({
    required this.kodeCabang,
    required this.memberId,
    required this.actionType,
    this.reffNumber, // Tanda tanya (?) menunjukkan parameter opsional
    this.branchid,
    this.amount,
    this.idmember,
    this.datetime,
    this.uid,
  });

  void someFunction(Uint8List uint8List) {
    String hexString = uint8ListToHexString(uint8List);
  }

  String? kodeCabang;
  String? memberId;
  String? actionType;
  String? reffNumber; // Tambahkan parameter reffNumber dengan tanda tanya (?)
  String? branchid; // Tambahkan parameter branchid dengan tanda tanya (?)
  String? amount; // Tambahkan parameter amount dengan tanda tanya (?)
  String? idmember; // Tambahkan parameter idmember dengan tanda tanya (?)
  String? datetime; // Tambahkan parameter datetime dengan tanda tanya (?)
  String? uid; // Tambahkan parameter uid dengan tanda tanya (?)

  NfcTag? tag;

  Map<String, dynamic>? additionalData;
  String? responseOut;

  Future<String?> handleTag(NfcTag tag, BuildContext context) async {
    this.tag = tag;
    additionalData = {};

    Object? tech;
    String? uid;

    final baseUrl = BaseUrl();
    final resetPinUrl = baseUrl.postResetPinMember();
    final topUpMember = baseUrl.topUpMember();

    if (Platform.isAndroid) {
      final mifare = MifareClassic.from(tag);
      if (mifare == null) {
        print('Tag is not compatible with MiFare.');
      } else {
        final uidHex = uint8ListToHexString(mifare.identifier);
        print('UID Kartu: $uidHex');
        String mifareId = uidHex;

        int uidDecimal = int.parse(uidHex, radix: 16);

        print(mifareId);

        if (actionType == "resetpin") {
          final url = Uri.parse(resetPinUrl);
          final response = await http.post(
            url,
            body: {
              'kodecabang': kodeCabang ?? '',
              'memberid': memberId ?? '',
              'uid': uidHex,
            },
          );

          // print(response.body);

          if (response.statusCode == 200) {
            responseOut = "Reset Pin"; // Atur nilai di sini
            print('POST request berhasil dengan ID : $memberId');
            print('POST request berhasil dengan Kode Cabang : $kodeCabang');
          } else {
            responseOut =
                "Gagal Scan / Gangguan Jaringan"; // Atur nilai di sini
            print('Gagal melakukan POST request');
          }
        } else if (actionType == "topup") {
          final now = DateTime.now();
          final formattedDateTime =
              DateFormat('yyyy-MM-dd HH:mm:ss').format(now);

          // Mengambil userid dari SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          final userid = prefs.getString('userid') ?? '';

          final url = Uri.parse(topUpMember);
          final response = await http.post(
            url,
            body: {
              'trx_code': '01',
              'reff_number': userid ?? '',
              'branchid': kodeCabang ?? '',
              'amount': amount ?? '',
              'idmember': memberId ?? '',
              'datetime': formattedDateTime,
              'uid': uidHex
            },
          );

          print(actionType);
          print(response);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final results = data;

            print(results);
            responseOut = "Top Up Member"; // Atur nilai di sini

            final rc = results['rc'].toString();
            final responseMessage = results['responsemesage'].toString();
            final amount = results['amount'].toString();
            final balance = results['balance'].toString();
            final closebalance = results['closebalance'].toString();
            final member = results['member'].toString();
            final datetime = results['datetime'].toString();
            final reff_number = results['reff_number'].toString();
            final trx_code = results['trx_code'].toString();
            final idmember = results['idmember'].toString();

            // Navigasi ke halaman print_invoice.dart dengan memberikan parameter
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PrintInvoice(
                  title: 'Print Preview',
                  date: datetime,
                  txCode: trx_code,
                  cardNumber: uidDecimal.toString(),
                  memberName: member,
                  amount: amount,
                  idmember: idmember,
                  balance: balance,
                  closebalance: closebalance,
                ),
              ),
            );
          } else {
            responseOut =
                "Gagal Scan / Gangguan Jaringan"; // Atur nilai di sini
            print('Gagal melakukan POST request');
          }

          responseOut = "Top Up"; // Atur nilai di sini
        }
      }
    }

    notifyListeners();
    return '$responseOut Berhasil.';
  }
}

class TagReadPage extends StatelessWidget {
  final String kodeCabang;
  final String memberId;
  final String actionType;
  String? amount;

  TagReadPage(
      {required this.kodeCabang,
      required this.memberId,
      required this.actionType,
      this.amount});
  Widget withDependency() => ChangeNotifierProvider<TagReadModel>(
        create: (context) => TagReadModel(
          kodeCabang: kodeCabang,
          memberId: memberId,
          actionType: actionType,
          amount: amount,
        ),
        child: TagReadPage(
            kodeCabang: kodeCabang,
            memberId: memberId,
            actionType: actionType,
            amount: amount),
      );

  @override
  Widget build(BuildContext context) {
    double heightR, widthR;
    heightR = MediaQuery.of(context).size.height / 1080; //v26
    widthR = MediaQuery.of(context).size.width / 2400;
    var curR = widthR;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
            onPressed: () {
              Navigator.of(context).pop();
            }),
        backgroundColor: AppColor.baseColor,
        title: Text(
          'NFC Read - $actionType [$kodeCabang]',
          style: TextStyle(color: AppColor.darkOrange),
        ),
        actions: <Widget>[],
      ),
      body: ListView(
        padding: EdgeInsets.all(4 * heightR),
        children: [
          FormSection(
            children: [
              FormRow(
                title: Text('Mulai Scanning untuk ($memberId)',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary)),
                onTap: () => startSession(
                  context: context,
                  handleTag: (tag) =>
                      Provider.of<TagReadModel>(context, listen: false)
                          .handleTag(tag,
                              context), // Memasukkan context ke dalam handleTag
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
