// ignore_for_file: use_key_in_widget_constructors, duplicate_ignore, use_build_context_synchronously

import 'dart:convert';

// ignore_for_file: use_key_in_widget_constructors

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/camera/camera_capture.dart';
import 'package:app_dart/src/views/error/network_error.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MemberAdd extends StatelessWidget {
  final TextEditingController registrationIdController =
      TextEditingController();
  final TextEditingController registrationNameController =
      TextEditingController();
  final TextEditingController memberNameController = TextEditingController();
  final TextEditingController areaController = TextEditingController();
  final TextEditingController roomController = TextEditingController();
  final TextEditingController caseController = TextEditingController();

  final MemberController _controller = MemberController();
  String branchid = '';
  String userId = '';
  bool isSubmitting = false;

  // Future<UserData> _getSharedPreferencesData() async {
  //   // final prefs = await SharedPreferences.getInstance();
  //   // final branchId = prefs.getString('branchid') ?? '';
  //   // final userId = prefs.getString('userid') ?? '';

  //   // SharedPreferences prefs = await SharedPreferences.getInstance();
  //   // branchid = prefs.getString('branchid') ??
  //   //     '';
  //   //     userId = prefs.getString('userid') ??
  //   //     '';
  //   // ignore: avoid_print
  //   print('Branch ID: $branchid');
  //   // ignore: avoid_print
  //   print('User ID: $userId');
  //   // return UserData(branchId, userId);
  // }

  Future<void> submitForm(BuildContext context) async {
    isSubmitting = true;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    branchid = prefs.getString('branchid') ?? '';
    userId = prefs.getString('userid') ?? '';

    // final userData = await _getSharedPreferencesData();
    final baseUrl = BaseUrl();
    if (registrationIdController.text.isEmpty ||
        registrationNameController.text.isEmpty ||
        memberNameController.text.isEmpty ||
        areaController.text.isEmpty ||
        roomController.text.isEmpty ||
        caseController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Semua field harus diisi.'),
          duration: Duration(seconds: 3),
        ),
      );
      return; // Jangan lanjutkan jika ada field yang kosong
    }

    // final postMemberUrl = await BaseUrl.getServerIpAddress();
    // final String apiUrl = 'http://$postMemberUrl/members/crud_members';

    final apiUrl = baseUrl.memberCrudAction();

    // ignore: avoid_print
    print(apiUrl);

    final Map<String, dynamic> postData = {
      'Id': "0",
      'Active': "true",
      'RegistrationId': registrationIdController.text,
      'RegistrationName': registrationNameController.text,
      'MemberName': memberNameController.text,
      'Area': areaController.text,
      'Room': roomController.text,
      'Case': caseController.text,
      'BranchId': branchid,
      'Userid': userId,
    };

    // ignore: avoid_print
    print(postData);

    try {
      buildShowDialog(context);

      final response = await http.post(
        Uri.parse(apiUrl),
        body: postData,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // ignore: avoid_print
        print(jsonResponse);
        final success = jsonResponse['success'];

        if (success['success'] == true) {
          final id = success['Id'];
          final message = success['message'];

          // Tutup loading dialog setelah delay 1 detik
          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();

            // Tampilkan Snackbar sukses
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('ID: $id, Message: $message'),
                duration: Duration(seconds: 3),
              ),
            );

            // Navigasi ke halaman berikutnya
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => ImageUpload(
                  memberId: id.toString(),
                  showSkipButton: true,
                ),
              ),
            );
          });

          // Navigator.of(context).pushReplacement(
          //   MaterialPageRoute(
          //     builder: (context) => MemberListScreen(
          //       members: _controller.fetchMembers(
          //           sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
          //       currentSort: 'ASC',
          //     ),
          //   ),
          // );
        } else {
          final message = success['message'];

          Future.delayed(Duration(seconds: 1), () {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error Message: $message'),
                // ignore: prefer_const_constructors
                duration: Duration(seconds: 3),
              ),
            );
          });
        }
      } else {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => NetworkErrorPage(),
        ));
      }
    } catch (error) {
      Future.delayed(Duration(seconds: 1), () {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          // ignore: prefer_const_constructors
          SnackBar(
            // ignore: prefer_const_constructors
            content: Text('Terjadi kesalahan selama permintaan HTTP.'),
            // ignore: prefer_const_constructors
            duration: Duration(seconds: 3),
          ),
        );
      });
    } finally {
      // Setelah selesai, kembalikan variabel isSubmitting menjadi false
      isSubmitting = false;
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          // ignore: prefer_const_constructors
          icon: Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        backgroundColor: AppColor.baseColor,
        // ignore: prefer_const_constructors
        title: Text(
          'Tambah Anggota',
          style: const TextStyle(color: AppColor.darkOrange),
        ),
      ),
      body: ListView(
        // ignore: prefer_const_constructors
        padding: EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: registrationIdController,
            // ignore: prefer_const_constructors
            decoration: InputDecoration(labelText: 'Registration ID'),
          ),
          TextFormField(
            controller: registrationNameController,
            // ignore: prefer_const_constructors
            decoration: InputDecoration(labelText: 'Registration Name'),
          ),
          TextFormField(
            controller: memberNameController,
            // ignore: prefer_const_constructors
            decoration: InputDecoration(labelText: 'Member Name'),
          ),
          TextFormField(
            controller: areaController,
            // ignore: prefer_const_constructors
            decoration: InputDecoration(labelText: 'Area'),
          ),
          TextFormField(
            controller: roomController,
            // ignore: prefer_const_constructors
            decoration: InputDecoration(labelText: 'Room'),
          ),
          TextFormField(
            controller: caseController,
            // ignore: prefer_const_constructors
            decoration: InputDecoration(labelText: 'Case'),
          ),
          Padding(
            // ignore: prefer_const_constructors
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {
                submitForm(context);
              },
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(AppColor.baseColor),
                shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                elevation: MaterialStateProperty.all<double>(
                    8.0), // Atur tinggi shadow sesuai keinginan
                shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                minimumSize: MaterialStateProperty.all<Size>(
                  // ignore: prefer_const_constructors
                  Size(200.0, 50.0),
                ),
              ),
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}

buildShowDialog(BuildContext context) {
  return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(),
        );
      });
}
