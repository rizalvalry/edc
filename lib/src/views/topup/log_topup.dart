import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:app_dart/src/views/topup/print_invoice.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LogTopUpPage extends StatefulWidget {
  @override
  _LogTopUpPageState createState() => _LogTopUpPageState();
}

class _LogTopUpPageState extends State<LogTopUpPage> {
  String rcValue = '';
  String responseMessageValue = '';
  String dateTime = ''; // Perbarui dari datetime menjadi dateTime
  String trxCode = ''; // Perbarui dari trx_code menjadi trxCode
  String? uidDecimal;
  String memberName = '';
  String amountValue = '';
  String idmember = '';
  String balanceValue = '';
  String closebalanceValue = '';

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
          width: double.infinity, // Lebar container mengisi seluruh layar
          margin: EdgeInsets.all(16.0), // Margin eksternal container
          padding: EdgeInsets.all(16.0), // Padding internal container
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/ramp-banner-background-sm.png'),
              fit: BoxFit.cover, // Sesuaikan ukuran gambar dengan container
            ),
            // color: Colors.white, // Warna latar belakang container
            borderRadius: BorderRadius.circular(20.0), // Radius sudut 20%
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5), // Warna shadow
                spreadRadius: 5, // Penyebaran shadow
                blurRadius: 7, // Ketajaman shadow
                offset: Offset(0, 3), // Posisi shadow (x, y)
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'RC Value: $rcValue',
                style: TextStyle(fontSize: 18),
              ),
              Text(
                'Response Message: $responseMessageValue',
                style: TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 20),

              // ... tambahkan lebih banyak Text Widgets sesuai kebutuhan
              ElevatedButton(
                onPressed: () {
                  // Navigasi ke halaman PrintInvoice dengan parameter-parameter yang sesuai
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
                },
                style: ElevatedButton.styleFrom(
                  primary: AppColor.darkOrange, // Warna latar belakang tombol
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        10.0), // Atur radius sesuai keinginan
                  ),
                  minimumSize: Size(
                    200.0,
                    50.0,
                  ), // Sesuaikan ukuran sesuai keinginan (lebar x tinggi)
                ),
                child: Text('PRINT LAST TOPUP',
                    style: TextStyle(color: AppColor.baseColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
