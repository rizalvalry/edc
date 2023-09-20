import 'package:shared_preferences/shared_preferences.dart';

class BaseUrl {
  static String? serverIpAddress;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    serverIpAddress = prefs.getString('serveripaddress') ?? '';

    // print(serverIpAddress);
  }

// // URL UTAMA/INDUK
  static const String deviceAuthorizedUrl =
      'http://192.168.18.103/wartelsus/edc/device_authorized?';

  static const String getNotifApiBaseUrl =
      'http://192.168.18.103/wartelsus/edc/notifapi';

// // END URL UTAMA

  static Future<String> getServerIpAddress() async {
    final prefs = await SharedPreferences.getInstance();
    final serverIpAddress = prefs.getString('serveripaddress') ??
        ''; // Default kosong jika tidak ditemukan
    return serverIpAddress;
  }

  // Fungsi untuk mendapatkan URL getUserIdByImei secara langsung
  static Future<String> getUserIdByImeiUrlDirectly(String imei) async {
    final serverIpAddress = await BaseUrl.getServerIpAddress();
    print('test dapat IP');
    print(serverIpAddress);
    return 'http://$serverIpAddress/edc/GETuseridbyimei?phoneimei=$imei';
  }

  static Future<String> getMemberListUrl() async {
    final serverIpAddress = await getServerIpAddress();
    return 'http://$serverIpAddress/members/memberslistmobile';
  }

  static Future<String> getMemberImageBaseUrl() async {
    final serverIpAddress = BaseUrl.serverIpAddress;
    return 'http://$serverIpAddress/resources/members';
  }

  String getMemberPropertiesBaseUrl() {
    final serverIpAddress = BaseUrl.serverIpAddress;
    return 'http://$serverIpAddress/members/properties';
  }

  String postResetPinMember() {
    final serverIpAddress = BaseUrl.serverIpAddress;
    return 'http://$serverIpAddress/members/reset_pin';
  }
}
