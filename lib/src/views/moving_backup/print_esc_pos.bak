// import 'package:flutter/material.dart';
// import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:esc_pos_printer/esc_pos_printer.dart';

// void main() {
//   runApp(PrintInvoice());
// }

// class PrintInvoice extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Cetak Struk'),
//         ),
//         body: StrukWidget(),
//       ),
//     );
//   }
// }

// class StrukWidget extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: ElevatedButton(
//         onPressed: () async {
//           await printReceipt();
//         },
//         child: Text('Cetak Struk'),
//       ),
//     );
//   }

//   Future<void> printReceipt() async {
//     const PaperSize paper = PaperSize.mm80;
//     final profile = await CapabilityProfile.load();
//     final printer = NetworkPrinter(paper, profile);

//     final PosPrintResult connect =
//         await printer.connect('127.0.0.1', port: 4554);

//     if (connect == PosPrintResult.success) {
//       printer.text('Anugerah Vata Abadi',
//           styles: PosStyles(align: PosAlign.center, height: PosTextSize.size2));
//       printer.text('DATE/TIME: 2023-09-19 14:30');
//       printer.text('TX CODE: 123456');
//       printer.text('JUMLAH TOPUP: Rp. 100.000');
//       printer.text('Nomor Kartu: 1234-5678-9012-3456');
//       printer.text('Nama Member: John Doe');
//       printer.text('Saldo Awal: Rp. 50.000');
//       printer.text('Saldo Akhir: Rp. 150.000');
//       printer.text('-------------------------------');

//       printer.cut();
//       printer.disconnect();
//     }
//     print('Print result: ${connect.msg}');
//   }
// }
