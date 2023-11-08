// ignore_for_file: unused_import, unused_local_variable, avoid_print, non_constant_identifier_names, use_build_context_synchronously, use_key_in_widget_constructors, deprecated_member_use, must_be_immutable, body_might_complete_normally_nullable

import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/config/my_utils.dart';
import 'package:app_dart/src/views/auth/ndef_record.dart';
import 'package:app_dart/src/views/auth/nfc_session.dart';
import 'package:device_info/device_info.dart';
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
    this.kodeCabang,
    this.memberId,
    this.actionType,
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

  String reponseUid = "";

  Future<String?> handleTag(NfcTag tag, BuildContext context) async {
    this.tag = tag;
    additionalData = {};

    Object? tech;
    String? uid;
    // final res = responseMessage;

    final baseUrl = BaseUrl();
    final updateUidCard = baseUrl.postUpdateUID();

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
        print(actionType);

        if (actionType == "uid") {
          print('UID Kartu: $uidHex');
          final url = Uri.parse(updateUidCard);

          final baseUrl = BaseUrl();
          final androidInfo = await DeviceInfoPlugin().androidInfo;
          final imei = androidInfo.androidId;

          final Map<String, dynamic> postData = {
            'value': uidHex,
            'recordId': 'UID',
            'phoneimei': imei,
          };

          final response = await http.post(
            url,
            body: postData,
          );

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            final success = data['success'];
            final message = data['message'];
            print(message);
            if (success == true) {
              // Respons sesuai dengan yang diharapkan
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColor.baseColor,
                    contentTextStyle: TextStyle(color: Colors.white),
                    title: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green, // Warna ikon checklist
                        ),
                        SizedBox(width: 8), // Jarak antara ikon dan teks
                        Text(
                          'Berhasil Terdaftar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Tutup',
                            style: TextStyle(color: Colors.white)),
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
                      ),
                    ],
                    content: Text('Kartu Anda telah berhasil didaftarkan.',
                        style: TextStyle(color: Colors.white)),
                  );
                },
              );
            } else if (message.isNotEmpty) {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColor.dangerColor,
                    contentTextStyle: TextStyle(color: Colors.white),
                    title: Text('Gagal Mendaftarkan Kartu!',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                      message,
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Tutup',
                            style: TextStyle(color: Colors.white)),
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
                      ),
                    ],
                  );
                },
              );
            } else {
              // Respons tidak sesuai dengan yang diharapkan
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    backgroundColor: AppColor.dangerColor,
                    contentTextStyle: TextStyle(color: Colors.white),
                    title: Text('Gagal Mendaftarkan Kartu!',
                        style: TextStyle(color: Colors.white)),
                    content: Text(
                      'Kartu Anda gagal didaftarkan. Silakan coba lagi.',
                      style: TextStyle(color: Colors.white),
                    ),
                    actions: <Widget>[
                      TextButton(
                        child: Text('Tutup',
                            style: TextStyle(color: Colors.white)),
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
                      ),
                    ],
                  );
                },
              );
            }
          }
        }
      }
    }

    // return "Pendaftaran Kartu UID berhasil";
  }
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
          title: Text(
            'NFC Read - $actionType [$kodeCabang]',
            style: const TextStyle(color: AppColor.darkOrange),
          ),
          actions: const <Widget>[],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
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
                ),
                child: const Text(
                  "RESET PIN MEMBER",
                  style: TextStyle(fontSize: 18.0, color: AppColor.darkOrange),
                ),
              ),
            ],
          ),

          // FormSection(
          //   children: [
          //     FormRow(
          //       title: Text('Mulai Scanning untuk ($memberId)',
          //           style: TextStyle(
          //               color: Theme.of(context).colorScheme.primary)),
          // onTap: () => startSession(
          //   context: context,
          //   handleTag: (tag) =>
          //       Provider.of<TagReadModel>(context, listen: false)
          //           .handleTag(tag,
          //               context), // Memasukkan context ke dalam handleTag
          // ),
          //     ),
          //   ],
          // ),
        ));
  }
}
