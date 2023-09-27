import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/models/member.dart';
import 'package:app_dart/src/views/member_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

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

  Future<UserData> _getSharedPreferencesData() async {
    final prefs = await SharedPreferences.getInstance();
    final branchId = prefs.getString('branchid') ?? '';
    final userId = prefs.getString('userid') ?? '';
    print('Branch ID: $branchId');
    print('User ID: $userId');
    return UserData(branchId, userId);
  }

  Future<void> submitForm(BuildContext context) async {
    final userData = await _getSharedPreferencesData();

    // final postMemberUrl = await BaseUrl.getServerIpAddress();
    // final String apiUrl = 'http://$postMemberUrl/members/crud_members';

    final baseUrl = BaseUrl();

    final apiUrl = baseUrl.memberAddAction();

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
      'BranchId': userData.branchId,
      'Userid': userData.userId,
    };

    print(postData);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: postData,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        print(jsonResponse);
        final success = jsonResponse['success'];

        if (success['success'] == true) {
          final id = success['Id'];
          final message = success['message'];

          // Tampilkan Snackbar sukses
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ID: $id, Message: $message'),
              duration: Duration(seconds: 3),
            ),
          );

          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => MemberListScreen(
                members: _controller.fetchMembers(
                    sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                currentSort: 'ASC',
              ),
            ),
          );
        } else {
          final message = success['message'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error Message: $message'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {}
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan selama permintaan HTTP.'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
        backgroundColor: AppColor.baseColor,
        title: Text('Tambah Anggota', style: TextStyle(color: AppColor.darkOrange),),
      ),
      body: ListView(
        padding: EdgeInsets.all(16.0),
        children: [
          TextFormField(
            controller: registrationIdController,
            decoration: InputDecoration(labelText: 'Registration ID'),
          ),
          TextFormField(
            controller: registrationNameController,
            decoration: InputDecoration(labelText: 'Registration Name'),
          ),
          TextFormField(
            controller: memberNameController,
            decoration: InputDecoration(labelText: 'Member Name'),
          ),
          TextFormField(
            controller: areaController,
            decoration: InputDecoration(labelText: 'Area'),
          ),
          TextFormField(
            controller: roomController,
            decoration: InputDecoration(labelText: 'Room'),
          ),
          TextFormField(
            controller: caseController,
            decoration: InputDecoration(labelText: 'Case'),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              onPressed: () {
                submitForm(context);
              },
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(AppColor
                      .baseColor), // Ganti dengan warna latar belakang yang Anda inginkan
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10.0), // Atur radius sesuai keinginan
                    ),
                  ),
                  elevation: MaterialStateProperty.all<double>(
                      8.0), // Atur tinggi shadow sesuai keinginan
                  shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                  minimumSize: MaterialStateProperty.all<Size>(
                    Size(200.0,
                        50.0), // Sesuaikan ukuran sesuai keinginan (lebar x tinggi)
                  ),
                ),
              child: Text('Submit'),
            ),
          ),
        ],
      ),
    );
  }
}
