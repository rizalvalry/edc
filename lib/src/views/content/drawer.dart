// ignore_for_file: unused_local_variable, library_prefixes, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, deprecated_member_use

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/auth/nfc_session.dart';
import 'package:app_dart/src/views/auth/tag.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:app_dart/src/views/topup/log_topup.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

String getGreeting() {
  final currentTime = DateTime.now();
  final hour = currentTime.hour;

  if (hour >= 0 && hour < 10) {
    return 'Selamat Pagi';
  } else if (hour >= 10 && hour < 15) {
    return 'Selamat Siang';
  } else if (hour >= 15 && hour < 18) {
    return 'Selamat Sore';
  } else {
    return 'Selamat Malam';
  }
}

class CustomDrawer extends StatelessWidget {
  String actionType = 'uid';

  String getImagePathBasedOnTime() {
    final currentTime = DateTime.now();
    final formattedTime = DateFormat('HH:mm').format(currentTime);

    if (formattedTime.compareTo('00:00') >= 0 &&
        formattedTime.compareTo('09:00') < 0) {
      return 'assets/images/morning.png'; // Path gambar pagi
    } else if (formattedTime.compareTo('09:00') >= 0 &&
        formattedTime.compareTo('12:00') < 0) {
      return 'assets/images/afternoon.png'; // Path gambar siang
    } else if (formattedTime.compareTo('12:00') >= 0 &&
        formattedTime.compareTo('17:00') < 0) {
      return 'assets/images/evening.png'; // Path gambar sore
    } else {
      return 'assets/images/night.png'; // Path gambar malam
    }
  }

  Future<bool> _manageUidActivation(BuildContext context,
      {bool reset = false}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isUidActivated = prefs.getBool('isUidActivated') ?? false;

    print(isUidActivated);
    if (reset) {
      // Jika perlu mereset UID, tampilkan dialog konfirmasi
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Konfirmasi Reset UID'),
            content: Text('Apakah Anda yakin ingin mereset UID?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Tutup dialog
                },
                child: Text('Batal'),
              ),
              TextButton(
                onPressed: () async {
                  // Reset nilai isUidActivated di SharedPreferences
                  await prefs.setBool('isUidActivated', false);

                  // Pindah ke halaman MemberListScreen setelah mereset UID
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MemberListScreen(
                        members: MemberController()
                            .fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                        currentSort: 'ASC',
                      ),
                    ),
                  );
                },
                child: Text('Reset'),
              ),
            ],
          );
        },
      );
    } else {
      // Tampilkan nilai isUidActivated
      print('UID Activation Status: $isUidActivated');
    }

    // Ganti tipe kembalian menjadi Future<bool>
    return isUidActivated;
  }

  @override
  Widget build(BuildContext context) {
    double deviceHeight = MediaQuery.of(context).size.height;
    return Drawer(
      child: FutureBuilder<bool>(
        // Ganti FutureBuilder dengan tipe data boolean
        future: _manageUidActivation(context),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            bool isUidActivated = snapshot.data ?? false;

            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColor.baseColor,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PT. Anugerah Vata',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            getGreeting(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 10),
                          ClipOval(
                            child: Image.asset(
                              getImagePathBasedOnTime(),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Column(
                          children: [
                            Icon(
                              Icons.settings,
                              color: Colors.white,
                              size: 15,
                            ),
                            Text(
                              'Reset UID',
                              style: TextStyle(
                                fontSize: 5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          _manageUidActivation(context, reset: true);
                        },
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (context) => LogTopUpPage()),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColor.lightGrey,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 2,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 15,
                          backgroundImage:
                              AssetImage('assets/images/topup.png'),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'LOG Top Up',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          color: AppColor.baseColor,
                        ),
                      ],
                    ),
                  ),
                ),
                !isUidActivated
                    ? InkWell(
                        onTap: () async {
                          startSession(
                            context: context,
                            handleTag: (tag) async {
                              final tagReadModel = TagReadModel(
                                actionType: actionType,
                              );
                              return await tagReadModel.handleTag(tag, context);
                            },
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColor.lightGrey,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.3),
                                spreadRadius: 2,
                                blurRadius: 2,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundImage:
                                    AssetImage('assets/images/activated.png'),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Aktifkan UID',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Aktifkan UID Anda',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColor.baseColor,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: AppColor.baseColor,
                              ),
                            ],
                          ),
                        ),
                      )
                    : Container(),
              ],
            );
          } else {
            // Tampilkan loading atau widget lain selama Future belum selesai
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
