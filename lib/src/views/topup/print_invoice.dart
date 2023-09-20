// ignore_for_file: public_member_api_docs

import 'dart:typed_data';

// import 'package:app_dart/src/views/topup/print_invoice.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

Future<void> main() async {
  runApp(const PrintInvoice('Anugerah Vata Abadi'));
}

class PrintInvoice extends StatelessWidget {
  const PrintInvoice(this.title, {Key? key}) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text("Print Preview")),
        body: PdfPreview(
          build: (format) => _generatePdf(format, title),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }

  Future<Uint8List> _generatePdf(PdfPageFormat format, String title) async {
    final pdf = pw.Document(version: PdfVersion.pdf_1_5, compress: true);
    final font = await PdfGoogleFonts.nunitoExtraLight();

    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (context) {
          return pw.Container(
            padding: pw.EdgeInsets.all(15.0),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 25),
                pw.Text(
                  'Anugerah Vata Abadi',
                  style: pw.TextStyle(
                      fontSize: 20, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 25),
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        width: 1,
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 25),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // ...
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'DATE/TIME:',
                          style: pw.TextStyle(fontSize: 25),
                        ),
                        pw.Text(
                          '17-Sep-2023', textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 25,
                          ), // Atur align right
                        ),
                      ],
                    ),
                    pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          'TX CODE:',
                          style: pw.TextStyle(fontSize: 25),
                        ),
                        pw.Text(
                          '114', textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontSize: 25,
                          ), // Atur align right
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 25),
                pw.Container(
                  width: double.infinity,
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        width: 0, // Atur lebar border menjadi 0
                      ),
                    ),
                  ),
                ),
                pw.SizedBox(height: 25),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Nomor Kartu:',
                      style: pw.TextStyle(fontSize: 25),
                    ),
                    pw.Text(
                      '3423-3432-5666-0999',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Nama Member:',
                      style: pw.TextStyle(fontSize: 25),
                    ),
                    pw.Text(
                      'Alif Rahmat',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                        fontSize: 25,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf.save();
  }
}
