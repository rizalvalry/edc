import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/models/member_detail.dart';
// import 'package:app_dart/src/views/camera/camera_permission.dart';
import 'package:app_dart/src/views/camera_capture.dart';
import 'package:app_dart/src/views/member_list_screen.dart';
import 'package:app_dart/src/views/topup/print_invoice.dart';
import 'package:app_dart/src/views/topup/tag_read.dart';
import 'package:app_dart/src/views/topup/topup_member.dart';
// import 'package:cached_network_image/cached_network_image.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_dart/src/views/form_row.dart';
import 'package:app_dart/src/views/topup/nfc_session.dart';
import 'dart:convert';

import 'package:toggle_switch/toggle_switch.dart';

class MemberDetailScreen extends StatefulWidget {
  final String memberId;

  MemberDetailScreen({required this.memberId});

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with WidgetsBindingObserver {
  late Future<MemberDetail> _memberDetail;
  bool isStatusActive = false; // Inisialisasi status
  bool isLoading = false;

  String kodeCabang = '';
  String memberName = '';
  String actionType = 'resetpin';

  final http.Client _httpClient = http.Client();

  TextEditingController regIdController = TextEditingController();
  TextEditingController regNameController = TextEditingController();
  TextEditingController memberNameController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController perkaraController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController activeController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController balanceController = TextEditingController();

  void _updateMemberData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userid = prefs.getString('userid') ?? '';
    final branchid = prefs.getString('branchid') ?? '';

    final url =
        Uri.parse('http://192.168.18.103/wartelsus/members/crud_members');
    final response = await http.post(
      url,
      body: {
        'Id': widget.memberId.toString(),
        'Active': isStatusActive.toString(),
        'RegistrationId': regIdController.text,
        'RegistrationName': regNameController.text,
        'MemberName': memberNameController.text,
        'Area': areaController.text,
        'Room': roomController.text,
        'Case': perkaraController.text,
        'BranchId': branchid,
        'Userid': userid,
      },
    );

    setState(() {
      isLoading = false;
    });

    if (response.statusCode == 200) {
      final responseBody = json.decode(response.body);
      final message = responseBody['success']['message'];

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
        ),
      );

      // Refresh halaman MemberDetailScreen
      setState(() {
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => MemberListScreen(
            members: MemberController()
                .fetchMembers(sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
            currentSort: 'ASC',
          ),
        ));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal melakukan update"),
        ),
      );
    }
  }

  MemberDetail memberDetail = MemberDetail(
    memberId: 0,
    regId: '',
    regName: '',
    memberName: '',
    area: '',
    room: '',
    perkara: '',
    pin: '',
    active: '',
    branch: '',
    balance: '',
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this); // Tambahkan observer
    _memberDetail = MemberController().fetchMemberDetail(widget.memberId);
    // initCamera();
    _getKodeCabang();

    _memberDetail.then((detail) {
      setState(() {
        memberDetail = detail;
        isStatusActive = memberDetail.active == "1";
        regIdController.text = memberDetail.regId;
        regNameController.text = memberDetail.regName;
        memberNameController.text = memberDetail.memberName;
        areaController.text = memberDetail.area;
        roomController.text = memberDetail.room ?? '-';
        perkaraController.text = memberDetail.perkara;
        pinController.text = memberDetail.pin;
        activeController.text =
            memberDetail.active == "1" ? 'Aktif' : 'Tidak Aktif';
        branchController.text = memberDetail.branch;
        balanceController.text = memberDetail.balance;
      });
    });
  }

  _getKodeCabang() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    kodeCabang = prefs.getString('kodecabang') ??
        ''; // Menggunakan nilai default jika data tidak ditemukan
    print(kodeCabang);
    setState(
        () {}); // Membuat widget melakukan rebuild setelah mendapatkan kodecabang
  }

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      title: const Text("Detail Member",
          style: TextStyle(color: AppColor.darkOrange)),
      actions: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => TopUpMemberScreen(
                      memberId: widget.memberId,
                      kodeCabang: kodeCabang,
                      memberName: memberDetail.regName,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.touch_app,
                color: AppColor.darkOrange,
              ),
            ),

            Padding(
              padding: EdgeInsets.only(right: 15.0),
              child: InkWell(
                onTap: () {
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
                        child: TagReadPage(
                            kodeCabang: kodeCabang, // Lemparkan kodeCabang
                            memberId: widget.memberId, // Lemparkan memberId
                            actionType: actionType
                            // Anda bisa mengisi uid sesuai kebutuhan Anda
                            ),
                      ),
                    ),
                  );
                },
                child: Icon(
                  Icons.restore,
                  color: AppColor.darkOrange,
                ), //Reset Pin
              ),
            ), // Ikon yang ditambahkan di sebelah touch_app
          ],
        ),
      ],
      headerWidget: headerWidget(context),
      headerBottomBar: headerBottomBarWidget(),
      body: [
        Text(
          "ID : ${widget.memberId}",
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        CustomTextField(label: 'Reg ID', controller: regIdController),
        CustomTextField(
            label: 'Registrasi Nama', controller: regNameController),
        CustomTextField(
            label: 'Nama Anggota', controller: memberNameController),
        CustomTextField(label: 'Area', controller: areaController),
        CustomTextField(label: 'Room', controller: roomController),
        CustomTextField(label: 'Perkara', controller: perkaraController),
        // CustomTextField(label: 'Pin', controller: pinController),
        // CustomTextField(label: 'Status', controller: activeController),
        ToggleSwitch(
          minWidth: 90.0,
          initialLabelIndex: isStatusActive ? 0 : 1,
          activeBgColor: [Colors.green],
          inactiveBgColor: Colors.red,
          labels: ['Aktif', 'Tidak Aktif'],
          onToggle: (index) {
            setState(() {
              isStatusActive = index == 0;
            });
          },
        ),

        CustomTextField(label: 'Branch', controller: branchController),
        CustomTextField(label: 'Balance', controller: balanceController),
        ElevatedButton(
          onPressed: () {
            if (!isLoading) {
              _updateMemberData(); // Panggil fungsi untuk melakukan POST ke URL
            }
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(AppColor
                .baseColor), // Ganti dengan warna latar belakang yang Anda inginkan
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(10.0), // Atur radius sesuai keinginan
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
          child: isLoading
              ? CircularProgressIndicator(
                  // Tampilkan loading indicator saat isLoading adalah true
                  color: AppColor.darkOrange,
                )
              : Text("Update"),
        ),
        SizedBox(height: 20),
      ],
      fullyStretchable: true,
      backgroundColor: Colors.white,
      appBarColor: AppColor.baseColor,
    );
  }

  Row headerBottomBarWidget() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageUpload(memberId: widget.memberId),
              ),
            );
          },
          icon: const Icon(Icons.camera_alt),
          color: AppColor.darkOrange,
        ),
      ],
    );
  }

  Widget headerWidget(BuildContext context) {
    final imageUrl = MemberController().getImageUrl(widget.memberId);

    return Container(
      color: AppColor.baseColor,
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Center(
        child: Column(
          children: [
            SizedBox(height: 15.0),
            FutureBuilder<Widget>(
              future: MemberController().loadImage(imageUrl),
              builder: (context, imageSnapshot) {
                if (imageSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (imageSnapshot.hasError) {
                  return Icon(Icons.error);
                } else {
                  return imageSnapshot.data ?? Container();
                }
              },
            ),
            SizedBox(height: 5.0),
            Text(
              '${memberDetail.regName}',
              style: TextStyle(
                fontSize: 17.0,
                fontWeight: FontWeight.bold,
                color: AppColor.darkOrange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;

  CustomTextField({required this.label, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.0),
          TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: myInputBorder(),
              enabledBorder: myInputBorder(),
              focusedBorder: myFocusBorder(),
              hintText: 'Enter $label',
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  OutlineInputBorder myInputBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: AppColor.baseColor,
        width: 2,
      ),
    );
  }

  OutlineInputBorder myFocusBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: AppColor.darkOrange,
        width: 2,
      ),
    );
  }
}
