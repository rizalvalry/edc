// ignore_for_file: unused_local_variable, library_prefixes, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, deprecated_member_use

import 'dart:typed_data';

import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;
import 'package:printing/printing.dart';

class PrintSettlement extends StatelessWidget {
  final String title;
  final String date;
  final String settlementNo;
  final List<Map<String, dynamic>> transactions;

  PrintSettlement({
    required this.title,
    required this.date,
    required this.settlementNo,
    required this.transactions,
  });

  Future<void> _printSettlement(BuildContext context) async {
    final pdf = pdfLib.Document();
    double totalAmount = 0.0;
    int no = 1; // Nomor urut dimulai dari 1

    final bool isRePrint = title == 'Re Print Settlement';

    for (var transaction in transactions) {
      final baseAmount =
          double.tryParse(transaction['BASEAMOUNT'].toString()) ?? 0.0;
      totalAmount += baseAmount;

      transaction['NO'] =
          no.toString(); // Menambahkan nomor urut ke setiap transaksi
      no++;
    }

    pdf.addPage(
      pdfLib.MultiPage(
        build: (context) => [
          pdfLib.Text('Anugerah Vata Abadi',
              style: pdfLib.TextStyle(
                  fontWeight: pdfLib.FontWeight.bold, fontSize: 25)),
          pdfLib.Text("=================================",
              style: pdfLib.TextStyle(fontSize: 25)),
          pdfLib.Paragraph(
            style: pdfLib.TextStyle(fontSize: 22),
            text: 'SETTLEMENT #$settlementNo',
          ),
          pdfLib.Paragraph(
            style: pdfLib.TextStyle(fontSize: 22),
            text: 'SETTLEMENT #WARTELSUS',
          ),
          pdfLib.Text("=================================",
              style: pdfLib.TextStyle(fontSize: 25)),
          pdfLib.Table.fromTextArray(
            border: pdfLib.TableBorder.symmetric(
              inside: pdfLib.BorderSide.none,
              outside: pdfLib.BorderSide.none,
            ),
            headerStyle: pdfLib.TextStyle(
              fontSize: 20, // Besarkan font untuk header
              fontWeight: pdfLib.FontWeight.bold,
              // font: boldFont, // Gunakan font bold
            ),
            cellStyle: const pdfLib.TextStyle(
              fontSize: 18, // Besarkan font untuk sel
              // font: regularFont, // Gunakan font reguler
            ),
            data: <List<String>>[
              <String>['NO', 'TIME', 'TX', 'ID', 'AMOUNT'],
              for (var transaction in transactions)
                <String>[
                  transaction['NO'],
                  transaction['TRANSTIMESTAMP'].toString(),
                  transaction['INVOICEID'].toString(),
                  transaction['LEVE_MEMBERID'].toString(),
                  transaction['BASEAMOUNT'].toString(),
                ],
            ],
          ),
          pdfLib.Paragraph(
            style: pdfLib.TextStyle(fontSize: 22),
            text: 'SETTLEMENT Rp. ${totalAmount.toStringAsFixed(2)}',
          ),
          pdfLib.Text("---------------------------------",
              style: pdfLib.TextStyle(fontSize: 25)),
          pdfLib.Paragraph(
            style: pdfLib.TextStyle(fontSize: 22),
            text: '*** SIGNATURE NOT REQUIRED ***',
          ),
          isRePrint
              ? pdfLib.Paragraph(
                  style: pdfLib.TextStyle(fontSize: 22),
                  text: '*** CARDHOLDER COPY ***',
                )
              : pdfLib.Paragraph(
                  style: pdfLib.TextStyle(fontSize: 22),
                  text: '*** CARDHOLDER ***',
                ),
        ],
      ),
    );

    // pdf.addPage(
    //   pdfLib.MultiPage(
    //     build: (context) => [
    //       pdfLib.Container(
    //         alignment: pdfLib.Alignment.topLeft,
    //         child: pdfLib.Text(
    //           'Settlement Details',
    //           style: pdfLib.TextStyle(fontSize: 20, fontWeight: pdfLib.FontWeight.bold),
    //         ),
    //       ),
    //       pdfLib.Divider(),
    //       pdfLib.Container(
    //         alignment: pdfLib.Alignment.topLeft,
    //         child: pdfLib.Text(
    //           'Settlement No: $settlementNo',
    //           style: pdfLib.TextStyle(fontSize: 16, fontWeight: pdfLib.FontWeight.bold),
    //         ),
    //       ),
    //       pdfLib.Container(
    //         alignment: pdfLib.Alignment.topLeft,
    //         child: pdfLib.Text(
    //           'Transaction Details:',
    //           style: pdfLib.TextStyle(fontSize: 16, fontWeight: pdfLib.FontWeight.bold),
    //         ),
    //       ),
    //       pdfLib.ListView.builder(
    //         itemBuilder: (context, index) {
    //           final transaction = transactions[index];
    //           return pdfLib.Container(
    //             margin: pdfLib.EdgeInsets.symmetric(vertical: 8.0),
    //             child: pdfLib.Column(
    //               crossAxisAlignment: pdfLib.CrossAxisAlignment.start,
    //               children: [
    //                 pdfLib.Text(
    //                   'No: ${transaction['NO']}', // Menampilkan nomor urut
    //                   style: pdfLib.TextStyle(fontSize: 14, fontWeight: pdfLib.FontWeight.bold),
    //                 ),
    //                 pdfLib.Text(
    //                   'Invoice ID: ${transaction['INVOICEID']}',
    //                   style: pdfLib.TextStyle(fontSize: 14),
    //                 ),
    //                 pdfLib.Text(
    //                   'Invoice No: ${transaction['INVOICENO']}',
    //                   style: pdfLib.TextStyle(fontSize: 14),
    //                 ),
    //                 pdfLib.Text(
    //                   'Member: ${transaction['LEVE_MEMBERID']}',
    //                   style: pdfLib.TextStyle(fontSize: 14),
    //                 ),
    //                 pdfLib.Text(
    //                   'Transaction Time: ${transaction['TRANSTIMESTAMP']}',
    //                   style: pdfLib.TextStyle(fontSize: 14),
    //                 ),
    //                 pdfLib.Text(
    //                   'Amount: ${transaction['BASEAMOUNT']}',
    //                   style: pdfLib.TextStyle(fontSize: 14),
    //                 ),
    //                 // Tambahkan informasi lain sesuai kebutuhan
    //               ],
    //             ),
    //           );
    //         },
    //         itemCount: transactions.length,
    //       ),
    //       pdfLib.Divider(),

    //       pdfLib.Container(
    //         alignment: pdfLib.Alignment.topLeft,
    //         child: pdfLib.Text(
    //           'Total Settlement: ${totalAmount.toStringAsFixed(2)}',
    //           style: pdfLib.TextStyle(fontSize: 16, fontWeight: pdfLib.FontWeight.bold),
    //         ),
    //       ),
    //     ],
    //   ),
    // );
    final Uint8List pdfData = await pdf.save();

    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async {
      return pdfData; // Kembalikan data PDF yang telah disimpan
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => MemberListScreen(
          members: MemberController().fetchMembers(
            sort: 'LEVE_MEMBERNAME',
            dir: 'ASC',
          ),
          currentSort: 'ASC',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _printSettlement(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView.builder(
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return ListTile(
                title: Text('Invoice ID: ${transaction['INVOICEID']}'),
                subtitle:
                    Text('Transaction Time: ${transaction['TRANSTIMESTAMP']}'),
                // trailing: ElevatedButton(
                //   onPressed: () {
                //     // Tambahkan logika untuk re-print di sini
                //     _printSettlement(context);
                //   },
                //   child: Text('Re-Print'),
                // ),
              );
            },
          ),
        ),
      ),
    );
  }
}
