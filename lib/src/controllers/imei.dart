import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/views/error/network_error.dart';
import 'package:client_information/client_information.dart';
// import 'package:device_info/device_info.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

// validasi device from ZERO
// Future<String> buildDeviceAuthorizedURL() async {
//   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
//   String phoneImei = '';
//   String device = '';
//   String model = '';
//   String api = '';
//   int deviceType = 2;

//   if (Platform.isAndroid) {
//     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//     phoneImei = androidInfo.androidId;
//     device = androidInfo.device;
//     model = androidInfo.model;
//     api = androidInfo.version.release;
//   } else if (Platform.isIOS) {
//     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//     phoneImei = iosInfo.identifierForVendor;
//     device = iosInfo.name;
//     model = iosInfo.model;
//     api = iosInfo.systemVersion;
//   }

//   print('IMEI NYA : $phoneImei');
//   String url = '${BaseUrl.deviceAuthorizedUrl}'
//       'phoneimei=$phoneImei&'
//       'device=$device&'
//       'model=$model&'
//       'api=$api&'
//       'devicetype=$deviceType';

//   return url;
// }

Future<String> buildDeviceAuthorizedURL() async {
  ClientInformation androidInfo = await ClientInformation.fetch();

  String? phoneImei = androidInfo.deviceId;
  String? device = androidInfo.deviceName;
  String? model = androidInfo.deviceName;
  String? api = androidInfo.osVersion;
  int deviceType = 2;

  final prefs = await SharedPreferences.getInstance();
  if (prefs.getString('phoneImei') == null) {
    await prefs.setString('phoneImei', phoneImei);
    await prefs.setString('device', device);
    await prefs.setString('model', model);
    await prefs.setString('api', api);
  }

  print('IMEI NYA : $phoneImei');
  String url = '${BaseUrl.deviceAuthorizedUrl}'
      'phoneimei=$phoneImei&'
      'device=$device&'
      'model=$model&'
      'api=$api&'
      'devicetype=$deviceType';

  return url;
}

Future<String> buildDeviceAuthCheck() async {
  final prefs = await SharedPreferences.getInstance();
  final phoneImei = prefs.getString('phoneImei') ?? '';
  final device = prefs.getString('device') ?? '';
  final model = prefs.getString('model') ?? '';
  final api = prefs.getString('api') ?? '';
  int deviceType = 2;

  print('IMEI NYA : $phoneImei');
  String url = '${BaseUrl.deviceAuthorizedUrl}'
      'phoneimei=$phoneImei&'
      'device=$device&'
      'model=$model&'
      'api=$api&'
      'devicetype=$deviceType';

  return url;
}

void handleNetworkError(BuildContext context) {
  // Navigasi ke NetworkErrorPage
  Navigator.of(context).pushReplacement(
    MaterialPageRoute(
      builder: (context) => NetworkErrorPage(),
    ),
  );
}

// push notifications
void sendRequestToLocalhostAPI(String imei, String model, String rc) async {
  try {
    final url = Uri.parse(
        '${BaseUrl.getNotifApiBaseUrl}?phoneimei=$imei&model=$model&rc=$rc');
    // ignore: avoid_print
    print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // final data = json.decode(response.body);
      // ignore: avoid_print
      print("Notifikasi Berhasil di kirimkan");
    } else {
      // ignore: avoid_print
      print('Gagal mengambil data dari API Notifikasi');
      handleNetworkError(context as BuildContext);
    }
  } catch (e) {
    // ignore: avoid_print
    handleNetworkError(context as BuildContext);
    print('Terjadi kesalahan: $e');
  }
}

// LOST CARD
void sendRequestToAPI(String imei, String model) async {
  try {
    final url = Uri.parse(
        '${BaseUrl.getNotifCardLostBaseUrl}?phoneimei=$imei&model=$model');
    // ignore: avoid_print
    print(url);
    final response = await http.get(url);

    if (response.statusCode == 200) {
      // final data = json.decode(response.body);
      // ignore: avoid_print
      print("Notifikasi Berhasil di kirimkan");
    } else {
      // ignore: avoid_print
      print('Gagal mengambil data dari API Notifikasi');
      handleNetworkError(context as BuildContext);
    }
  } catch (e) {
    // ignore: avoid_print
    handleNetworkError(context as BuildContext);
    print('Terjadi kesalahan: $e');
  }
}

// Get User By IMEI
// Future<String> buildDeviceAuthorizedIMEI() async {
//   final url = await buildDeviceAuthorizedURL();
//   final response = await http.get(Uri.parse(url));

//   if (response.statusCode == 200) {
//     final data = json.decode(response.body);
//     final results = data['results'];

//     if (results != null && results.isNotEmpty) {
//       final imei = results[0]['phoneimei'];
//       return imei;
//     }
//   }
//   throw Exception('Failed to get IMEI from device authorized');
// }

// Simpan Data User By result IMEI
Future<void> saveApiData(
    String branchId, String userId, String loginName) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('userid', userId);
  await prefs.setString('branchid', branchId);
  await prefs.setString('loginname', loginName);
}

// Future<void> saveApiUrl(String apiUrl) async {
//   final prefs = await SharedPreferences.getInstance();
//   await prefs.setString('apiUrl', apiUrl);
//   print(prefs);
// }


