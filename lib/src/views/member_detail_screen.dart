import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/models/member_detail.dart';
// import 'package:app_dart/src/views/camera/camera_permission.dart';
import 'package:app_dart/src/views/camera_capture.dart';
import 'package:app_dart/src/views/topup/print_invoice.dart';
import 'package:app_dart/src/views/topup/tag_read.dart';
import 'package:app_dart/src/views/topup/topup_member.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_dart/src/views/form_row.dart';
import 'package:app_dart/src/views/topup/nfc_session.dart';

class MemberDetailScreen extends StatefulWidget {
  final String memberId;

  MemberDetailScreen({required this.memberId});

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with WidgetsBindingObserver {
  late Future<MemberDetail> _memberDetail;
  bool _cameraInitialized = false;
  late CameraController _cameraController;

  String kodeCabang = '';
  String memberName = '';
  String actionType = 'resetpin';

  final http.Client _httpClient = http.Client();

  TextEditingController regIdController = TextEditingController();
  TextEditingController areaController = TextEditingController();
  TextEditingController roomController = TextEditingController();
  TextEditingController perkaraController = TextEditingController();
  TextEditingController pinController = TextEditingController();
  TextEditingController activeController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController balanceController = TextEditingController();

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
    initCamera();

    _getKodeCabang();

    _memberDetail.then((detail) {
      setState(() {
        memberDetail = detail;
        regIdController.text = memberDetail.regId;
        areaController.text = memberDetail.area;
        roomController.text = memberDetail.room ?? '-';
        perkaraController.text = memberDetail.perkara;
        pinController.text = memberDetail.pin;
        activeController.text = memberDetail.active;
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

  // Fungsi untuk membuka kamera
  Future<void> initCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      if (mounted) {
        setState(() {
          _cameraInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (_cameraController != null) {
        initCamera(); // Inisialisasi ulang kamera saat aplikasi dilanjutkan dari background
      }
    }
  }

  @override
  void dispose() {
    _cameraController.dispose();
    WidgetsBinding.instance!.removeObserver(this); // Hapus observer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      leading: const Icon(Icons.arrow_back_ios),
      title: const Text("Detail"),
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
              icon: const Icon(Icons.touch_app),
            ),
            // IconButton(
            //   onPressed: () {
            //     Navigator.of(context).push(
            //       MaterialPageRoute(
            //           builder: (context) =>
            //               PrintInvoice('Anugerah Vata abadi')),
            //     );
            //   },
            //   icon: const Icon(Icons.touch_app),
            // ),
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
                child: Icon(Icons.restore), //Reset Pin
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
        CustomTextField(label: 'Area', controller: areaController),
        CustomTextField(label: 'Room', controller: roomController),
        CustomTextField(label: 'Perkara', controller: perkaraController),
        CustomTextField(label: 'Pin', controller: pinController),
        CustomTextField(label: 'Active', controller: activeController),
        CustomTextField(label: 'Branch', controller: branchController),
        CustomTextField(label: 'Balance', controller: balanceController),
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
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Select Source'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          _openCamera(context); // Buka kamera
                        },
                        child: Text('Take Picture'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Tutup dialog
                          // _openGallery(context); // Buka galeri
                        },
                        child: Text('Get From Gallery'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          icon: const Icon(Icons.camera_alt),
          color: Colors.white,
        ),
      ],
    );
  }

  // Fungsi untuk membuka kamera
  void _openCamera(BuildContext context) async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TakePictureScreen(
          cameraController: CameraController(
            firstCamera,
            ResolutionPreset.medium,
          ),
          firstCamera: firstCamera,
        ),
      ),
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
                color: Colors.white,
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
        color: Colors.blue,
        width: 2,
      ),
    );
  }

  OutlineInputBorder myFocusBorder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: Colors.lightBlueAccent,
        width: 2,
      ),
    );
  }
}
