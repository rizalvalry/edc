// ignore_for_file: unnecessary_null_comparison, prefer_const_constructors, library_prefixes, use_key_in_widget_constructors, unnecessary_string_interpolations, deprecated_member_use

import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/flare_animation_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import library untuk format rupiah
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

class PrintInvoice extends StatelessWidget {
  final String title;
  final String date;
  final String txCode;
  final String cardNumber;
  final String memberName;
  final String amount;
  final String closebalance;
  final String balance;
  final String idmember;

  PrintInvoice(
      {required this.title,
      required this.date,
      required this.txCode,
      required this.cardNumber,
      required this.memberName,
      required this.amount,
      required this.closebalance,
      required this.balance,
      required this.idmember}) {
    assert(amount != null);
    assert(closebalance != null);
    assert(balance != null);
  }

  String formatCurrency(double value) {
    // Ubah nilai double menjadi format mata uang
    final currencyFormat =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');
    return currencyFormat.format(value);
  }

  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _printInvoice(BuildContext context) async {
    final pdf = pdfLib.Document();

    // Tambahkan desain isi teks ke dalam PDF
    pdf.addPage(
      pdfLib.MultiPage(
        build: (context) => [
          pdfLib.Container(
            alignment: pdfLib.Alignment.topLeft,
            child: pdfLib.Text(
              'Anugerah Vata Abadi',
              style: pdfLib.TextStyle(
                  fontSize: 20, fontWeight: pdfLib.FontWeight.bold),
            ),
          ),
          // pdfLib.Divider(),
          pdfLib.Text("=================================",
              style: pdfLib.TextStyle(fontSize: 25)),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('Invoice Date:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(date, style: pdfLib.TextStyle(fontSize: 22)),
              ],
            ),
          ),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('TX Code:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(txCode, style: pdfLib.TextStyle(fontSize: 22)),
              ],
            ),
          ),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('Nomor Kartu:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(cardNumber, style: pdfLib.TextStyle(fontSize: 22)),
              ],
            ),
          ),
          pdfLib.Text("=================================",
              style: pdfLib.TextStyle(fontSize: 25)),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('ID Member:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(idmember, style: pdfLib.TextStyle(fontSize: 22)),
              ],
            ),
          ),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('Nama Member:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(
                    '${memberName.length > 25 ? memberName.substring(0, 25) : memberName}',
                    style: pdfLib.TextStyle(fontSize: 22)),
              ],
            ),
          ),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('Jumlah:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text('${formatCurrency(double.parse(amount))}',
                    style: pdfLib.TextStyle(fontSize: 22)),
              ],
            ),
          ),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('Saldo Awal:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(
                  '${formatCurrency(double.parse(balance))}',
                  style: pdfLib.TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          pdfLib.Container(
            child: pdfLib.Row(
              mainAxisAlignment: pdfLib.MainAxisAlignment.spaceBetween,
              children: [
                pdfLib.Text('Saldo Akhir:',
                    style: pdfLib.TextStyle(
                        fontSize: 22, fontWeight: pdfLib.FontWeight.bold)),
                pdfLib.Text(
                  '${formatCurrency(double.parse(closebalance))}',
                  style: pdfLib.TextStyle(fontSize: 22),
                ),
              ],
            ),
          ),
          // pdfLib.Divider(),
          pdfLib.Text("=================================",
              style: pdfLib.TextStyle(fontSize: 25)),
        ],
      ),
    );

    // Cetak PDF
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdf.save();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Panggil metode cetak saat halaman dimuat
    _printInvoice(context);

    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          backgroundColor: AppColor.baseColor,
          title: Text(title),
        ),
        body: Card(
          elevation: 4, // Nilai elevation yang Anda inginkan

          child: Padding(
            padding: EdgeInsets.all(15),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invoice Date:',
                        style: TextStyle(fontSize: 15),
                      ),
                      Text(
                        '$date',
                        style: TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16), // Spasi antara teks dan tombol

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transaction Code:',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '$txCode',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Spasi antara teks dan tombol

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Card Number:',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '$cardNumber',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Spasi antara teks dan tombol

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Member Name:',
                      style: TextStyle(fontSize: 15),
                    ),
                    Text(
                      '${memberName.length > 25 ? memberName.substring(0, 25) : memberName}',
                      style: TextStyle(fontSize: 15),
                    ),
                  ],
                ),
                SizedBox(height: 16), // Spasi antara teks dan tombol

                SizedBox(height: 16), // Spasi antara teks dan tombol
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Jumlah TOPUP :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${formatCurrency(double.parse(amount))}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total SALDO :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${formatCurrency(double.parse(closebalance))}',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16),

                SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return FlareAnimationWidget(
                                scaffoldKey: scaffoldKey,
                                alertMessage: 'Success',
                                actionType: 'resetpin',
                                previousContext: context,
                              );
                            },
                          ),
                        );
                      },
                      icon: Icon(Icons.done),
                      label: Text('Selesai',
                          style: TextStyle(color: AppColor.darkOrange)),
                      style:
                          ElevatedButton.styleFrom(primary: AppColor.baseColor),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        _printInvoice(context);
                      },
                      icon: Icon(Icons.print),
                      label: Text('Re-Print'),
                      style: ElevatedButton.styleFrom(primary: Colors.orange),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }
}
