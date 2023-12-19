// ignore_for_file: unused_local_variable

import 'dart:convert';

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:app_dart/src/views/topup/print_invoice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogTopUpPage extends StatefulWidget {
  @override
  _LogTopUpPageState createState() => _LogTopUpPageState();
}

class _LogTopUpPageState extends State<LogTopUpPage> {
  String? rcValue = '';
  String? responseMessageValue = '';
  String? dateTime = '';
  String? trxCode = '';
  String? uidDecimal;
  String? memberName = '';
  String? amountValue = '';
  String? idmember = '';
  String? balanceValue = '';
  String? closebalanceValue = '';

  @override
  void initState() {
    super.initState();
    displayLastTopUpData();
    getUidDecimal();
  }

  // Fungsi untuk mengambil uidDecimal dari shared preferences
  Future<void> getUidDecimal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      uidDecimal = prefs.getString('uidDecimal');
    });
  }

  Future<void> displayLastTopUpData() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final lastTopUpData = sharedPreferences.getString('lastTopUpData');

    if (lastTopUpData != null) {
      final data = json.decode(lastTopUpData);
      final rc = data['rc'];
      final responseMessage = data['responsemesage'];
      final amount = data['amount'];
      final balance = data['balance'];
      final closebalance = data['closebalance'];
      final member = data['member'];
      final datetime = data['datetime'];
      final reff_number = data['reff_number'];
      final trx_code = data['trx_code'];
      final idmember = data['idmember'];

      // double amountValue = double.tryParse(amount) ?? 0.0;
      // double closebalanceValue = double.tryParse(closebalance) ?? 0.0;
      // double balanceValue = double.tryParse(balance) ?? 0.0;

      setState(() {
        rcValue = rc;
        responseMessageValue = responseMessage;
        dateTime = datetime;
        trxCode = trx_code;
        memberName = member;
        amountValue = amount;
        balanceValue = balance.toString();
        closebalanceValue = closebalance.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.baseColor,
        title: Text(
          'Log Top Up',
          style: TextStyle(color: AppColor.darkOrange),
        ),
        leading: IconButton(
          icon: const Icon(Icons.home, color: AppColor.darkOrange),
          onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
              builder: (context) => MemberListScreen(
                members: MemberController()
                    .fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                currentSort: 'ASC',
              ),
            ));
          },
        ),
      ),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ramp-banner-background-sm.png'),
              fit: BoxFit.cover,
            ),
            borderRadius: BorderRadius.circular(20.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Text(
              //   'RC Value: $rcValue',
              //   style: TextStyle(fontSize: 18),
              // ),
              Text(
                '$responseMessageValue',
                style: TextStyle(fontSize: 18, color: AppColor.darkOrange),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: rcValue == '00'
                    ? () {
                        // Navigasi ke halaman PrintInvoice
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => PrintInvoice(
                              title: 'Print Preview',
                              date: dateTime.toString(),
                              txCode: trxCode.toString(),
                              cardNumber: uidDecimal.toString(),
                              memberName: memberName.toString(),
                              amount: amountValue.toString(),
                              idmember: idmember.toString(),
                              balance: balanceValue.toString(),
                              closebalance: closebalanceValue.toString(),
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  primary: AppColor.darkOrange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  minimumSize: Size(
                    200.0,
                    50.0,
                  ),
                ),
                child: Text('PRINT LAST TOPUP',
                    style: TextStyle(color: AppColor.baseColor)),
              )
            ],
          ),
        ),
      ),
    );
  }
}
