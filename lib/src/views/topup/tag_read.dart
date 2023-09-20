import 'dart:io';
import 'dart:typed_data';
import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/config/my_utils.dart';
import 'package:app_dart/src/views/form_row.dart';
import 'package:app_dart/src/views/ndef_record.dart';
import 'package:app_dart/src/views/topup/nfc_session.dart';

import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class TagReadModel with ChangeNotifier {
  TagReadModel(
      {required this.kodeCabang,
      required this.memberId,
      required this.actionType});

  void someFunction(Uint8List uint8List) {
    String hexString = uint8ListToHexString(uint8List);
  }

  String? kodeCabang;
  String? memberId;
  String? actionType;

  NfcTag? tag;

  Map<String, dynamic>? additionalData;
  String? responseOut;

  Future<String?> handleTag(NfcTag tag) async {
    this.tag = tag;
    additionalData = {};

    Object? tech;
    String? uid;

    final baseUrl = BaseUrl(); // Buat objek BaseUrl
    final resetPinUrl = baseUrl.postResetPinMember();

    if (Platform.isAndroid) {
      final mifare = MifareClassic.from(tag);
      if (mifare == null) {
        print('Tag is not compatible with MiFare.');
      } else {
        final uidHex = uint8ListToHexString(mifare.identifier);
        print('UID Kartu: $uidHex');

        print(actionType);

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

          print(response.body);

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
          // isi parameter topup

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

  TagReadPage(
      {required this.kodeCabang,
      required this.memberId,
      required this.actionType});
  Widget withDependency() => ChangeNotifierProvider<TagReadModel>(
        create: (context) => TagReadModel(
            kodeCabang: kodeCabang, // Lemparkan kodeCabang
            memberId: memberId, // Lemparkan memberId
            actionType: actionType),
        child: TagReadPage(
            kodeCabang: kodeCabang, // Lemparkan kodeCabang
            memberId: memberId, // Lemparkan memberId
            actionType: actionType),
      );

  @override
  Widget build(BuildContext context) {
    double heightR, widthR;
    heightR = MediaQuery.of(context).size.height / 1080; //v26
    widthR = MediaQuery.of(context).size.width / 2400;
    var curR = widthR;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.baseColor,
        title: Text('NFC Read - Branch $kodeCabang'),
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
                  handleTag: Provider.of<TagReadModel>(context, listen: false)
                      .handleTag,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
