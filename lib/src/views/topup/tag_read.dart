// ignore_for_file: unused_import, unused_local_variable, avoid_print, non_constant_identifier_names, use_build_context_synchronously, use_key_in_widget_constructors, deprecated_member_use, must_be_immutable, body_might_complete_normally_nullable

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/app_text.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/config/my_utils.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/auth/ndef_record.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:app_dart/src/views/topup/nfc_session.dart';
import 'package:app_dart/src/views/topup/print_invoice.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    this.closebalance,
    this.balance,
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
  String? reffNumber;
  String? branchid;
  String? amount;
  String? closebalance;
  String? balance;
  String? idmember;
  String? datetime;
  String? uid;

  NfcTag? tag;

  Map<String, dynamic>? additionalData;
  String? responseOut;

  String? printMessage;
  String responseTopUpFirst = "";
  String responseTopUp = "";

  Future<String?> handleTag(NfcTag tag, BuildContext context) async {
    this.tag = tag;
    additionalData = {};

    Object? tech;
    String? uid;
    // final res = responseMessage;
    final prefs = await SharedPreferences.getInstance();
    final phoneImei = prefs.getString('phoneImei') ?? '';

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
              'imei': phoneImei
            },
          );

          final data = json.decode(response.body);
          final rcreset = data['rc'];
          final responMessage = data['responsemesage'];

          print(rcreset);

          if (response.statusCode == 200) {
            responseOut = "Reset Pin";
            print('POST request berhasil dengan ID : $memberId');
            print('POST request berhasil dengan Kode Cabang : $kodeCabang');
            printMessage = responMessage;
          } else if (rcreset != '00') {
            printMessage = responMessage;
          } else {
            responseOut = "Gagal Scan / Gangguan Jaringan";
            printMessage = responseOut;
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
              'reff_number': userid,
              'branchid': kodeCabang ?? '',
              'amount': amount ?? '',
              'idmember': memberId ?? '',
              'datetime': formattedDateTime,
              'uid': uidHex,
              'imei': phoneImei
            },
          );

          final data = json.decode(response.body);
          final rctopup = data['rc'];
          final responMessage = data['responsemesage'];

          print(rctopup);
          print(responMessage);
          print(actionType);
          print(response);

          if (response.statusCode == 200) {
            print('POST request berhasil dengan Kode Cabang : $kodeCabang');
            final data = json.decode(response.body);
            final results = data;

            responseTopUpFirst = results['responsemesage'].toString();

            // Simpan data ke SharedPreferences
            final sharedPreferences = await SharedPreferences.getInstance();
            sharedPreferences.setString('lastTopUpData', json.encode(results));

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

            print("check hasil topUP");
            print(responseMessage);

            double amountValue = double.tryParse(amount) ?? 0.0;
            double closebalanceValue = double.tryParse(closebalance) ?? 0.0;
            double balanceValue = double.tryParse(balance) ?? 0.0;

            // Simpan uidDecimal ke dalam shared preferences
            final prefs = await SharedPreferences.getInstance();
            prefs.setString('uidDecimal', uidDecimal.toString());

            if (rctopup != '00') {
              responseTopUpFirst = responMessage;
              showResponseAlertDialog(context, responseTopUpFirst);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => PrintInvoice(
                    title: 'Print Preview',
                    date: datetime,
                    txCode: trx_code,
                    cardNumber: uidDecimal.toString(),
                    memberName: member,
                    amount: amountValue.toString(),
                    idmember: idmember,
                    balance: balanceValue.toString(),
                    closebalance: closebalanceValue.toString(),
                  ),
                ),
              );
            }
          } else {
            responseOut = "Gagal Scan / Gangguan Jaringan";
            print('Gagal melakukan POST request');
          }

          responseOut = "Top Up";
          responseTopUp = responseTopUpFirst;
        }
      }
    }

    notifyListeners();

    if (responseOut == "Top Up") {
      return '${responseTopUp}';
    } else if (responseOut == "Reset Pin") {
      return '$printMessage';
    }
  }
}

void showResponseAlertDialog(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColor.dangerColor,
        contentTextStyle: TextStyle(color: Colors.white),
        title: Text('Response Top Up'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => MemberListScreen(
                    members: MemberController().fetchMembers(
                      sort: 'LEVE_MEMBERNAME',
                      dir: 'ASC',
                    ),
                    currentSort: 'ASC',
                  ),
                ),
              );
            },
            child: Text('Tutup'),
          ),
        ],
      );
    },
  );
}

class TagReadPage extends StatelessWidget {
  final String kodeCabang;
  final String memberId;
  final String actionType;
  String? amount;
  String? closebalance;
  String? balance;

  TagReadPage(
      {required this.kodeCabang,
      required this.memberId,
      required this.actionType,
      this.amount,
      this.closebalance,
      this.balance});
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
    heightR = MediaQuery.of(context).size.height / 0.0; // Tinggi layar dibagi 2
    widthR = MediaQuery.of(context).size.width / 0.0; // Lebar layar dibagi 2

    var curR = widthR;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              icon:
                  const Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
              onPressed: () {
                Navigator.of(context).pop();
              }),
          backgroundColor: AppColor.baseColor,
          title: AppText(
            'NFC Read - $actionType [$kodeCabang]',
            style: const TextStyle(color: AppColor.darkOrange),
          ),
          actions: const <Widget>[],
        ),
        body: Center(
          child: Container(
            width: double.infinity,
            // Tinggi setengah dari layar
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    'assets/images/reset-pin.png'), // Ganti dengan path gambar latar belakang Anda
                fit: BoxFit
                    .cover, // Sesuaikan sesuai kebutuhan (cover, contain, dll.)
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0, 0),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: () => startSession(
                      context: context,
                      handleTag: (tag) =>
                          Provider.of<TagReadModel>(context, listen: false)
                              .handleTag(tag, context),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: AppColor.baseColor,
                      onPrimary: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      padding: const EdgeInsets.all(16.0),
                      elevation: 8.0,
                    ),
                    child: Container(
                      child: const Text(
                        "RESET PIN MEMBER",
                        style: TextStyle(
                            fontSize: 18.0, color: AppColor.darkOrange),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
