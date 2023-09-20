import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/models/member_detail.dart';
import 'package:app_dart/src/views/topup/tag_read.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TopUpMemberScreen extends StatefulWidget {
  String memberId;
  String kodeCabang;
  String memberName;

  TopUpMemberScreen(
      {required this.memberId,
      required this.kodeCabang,
      required this.memberName}); // Tambahkan kodeCabang ke konstruktor

  @override
  _TopUpMemberScreenState createState() => _TopUpMemberScreenState();
}

class _TopUpMemberScreenState extends State<TopUpMemberScreen> {
  TextEditingController _nominalController = TextEditingController();
  final _currencyFormatter =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ');

  String kodeCabang = '';
  String actionType = 'topup';
  // String memberName = '';

  @override
  void initState() {
    super.initState();
    _getKodeCabang();
    // _nominalController.addListener(_onNominalChanged);
  }

  // Metode untuk mengambil kodecabang dari shared_preferences
  _getKodeCabang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      widget.kodeCabang = prefs.getString('kodecabang') ??
          ''; // Menggunakan nilai default jika data tidak ditemukan
    });
  }

  @override
  void dispose() {
    // _nominalController.removeListener(_onNominalChanged);
    // _nominalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const Icon(Icons.arrow_back_ios),
        backgroundColor: AppColor.baseColor,
        title: Text('Top-Up Member - Cabang ${widget.kodeCabang}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4.0,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    'ID ${widget.memberId} (${widget.memberName})',
                    style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey),
                  ),
                ),
                SizedBox(height: 16.0),
                Text(
                  'Jumlah Nominal : ${_currencyFormatter.format(double.tryParse(_nominalController.text) ?? 0)}',
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                TextField(
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    focusColor: Colors.blue,
                    border: OutlineInputBorder(),
                    hintText: 'Masukkan jumlah nominal',
                  ),
                ),
                SizedBox(height: 22.0),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MultiProvider(
                          providers: [
                            ChangeNotifierProvider<TagReadModel>(
                              create: (context) => TagReadModel(
                                  kodeCabang: kodeCabang,
                                  memberId: widget.memberId,
                                  actionType: actionType),
                            ),
                            // Tambahan penyedia lainnya jika diperlukan.
                          ],
                          //              child: TagReadPage(
                          //   kodeCabang: kodeCabang, // Lemparkan kodeCabang
                          //   memberId: memberId,     // Lemparkan memberId
                          //   uid: '',                 // Anda bisa mengisi uid sesuai kebutuhan Anda
                          // ),
                        ),
                      ),
                    );
                  },
                  child: Text('Top-Up Sekarang'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
