import 'dart:io';
import 'package:app_dart/src/config/base_url.dart';
import 'package:device_info/device_info.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// validasi device from ZERO
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

  String url = '${BaseUrl.deviceAuthorizedUrl}'
      'phoneimei=$phoneImei&'
      'device=$device&'
      'model=$model&'
      'api=$api&'
      'devicetype=$deviceType';

  return url;
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
    }
  } catch (e) {
    // ignore: avoid_print
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


