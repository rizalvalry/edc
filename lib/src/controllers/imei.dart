import 'dart:convert';
import 'dart:io';
import 'package:app_dart/src/models/member.dart';
import 'package:app_dart/src/models/member_detail.dart';
import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';

Future<String> buildDeviceAuthorizedURL() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  String phoneImei = '';
  String device = '';
  String model = '';
  String api = '';
  int deviceType = 2;

  if (Platform.isAndroid) {
    AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
    phoneImei = androidInfo.androidId;
    device = androidInfo.device;
    model = androidInfo.model;
    api = androidInfo.version.release;
  } else if (Platform.isIOS) {
    IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
    phoneImei = iosInfo.identifierForVendor;
    device = iosInfo.name;
    model = iosInfo.model;
    api = iosInfo.systemVersion;
  }

  String url = 'http://192.168.18.103/wartelsus/edc/device_authorized?'
      'phoneimei=$phoneImei&'
      'device=$device&'
      'model=$model&'
      'api=$api&'
      'devicetype=$deviceType';

  return url;
}

Future<void> _sendRequestToLocalhostAPI(String imei, String model) async {
  try {
    final url =
        Uri.parse('http://192.168.18.106/api/?phoneimei=$imei&model=$model');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
    } else {
      print('Gagal mengambil data dari URL http://192.168.18.106/api/');
    }
  } catch (e) {
    print('Terjadi kesalahan: $e');
  }
}
