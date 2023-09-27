import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PostRequestTest extends StatelessWidget {
  void _sendPostRequest(BuildContext context) async {
    final String apiUrl = 'http://192.168.18.103/wartelsus/members/crud_members';

        print(apiUrl);
 

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
        "Id": "0",
        "Active": "true",
        "RegistrationId": "858",
        "RegistrationName": "yuga bin hasan",
        "MemberName": "yua",
        "Area": "blok p",
        "Room": "blok g",
        "Case": "begal",
        "BranchId": "6",
        "Userid": "30"
        },
      );

        print(response);


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

        } else {
          final message = success['message'];

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error Message: $message'),
              duration: Duration(seconds: 3),
            ),
          );

        }
      } else {
      }
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
        title: Text('POST Request Test'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _sendPostRequest(context);
          },
          child: Text('Kirim POST Request'),
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: PostRequestTest(),
  ));
}
