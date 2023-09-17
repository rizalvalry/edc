import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/models/member_detail.dart';
import 'package:app_dart/src/views/camera_capture.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:camera/camera.dart';
import 'package:draggable_home/draggable_home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:camera/camera.dart';
import 'package:app_dart/src/controllers/member_controller.dart';


class MemberDetailScreen extends StatefulWidget {
  final String memberId;

  MemberDetailScreen({required this.memberId});

  @override
  _MemberDetailScreenState createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  late Future<MemberDetail> _memberDetail;
  late CameraController _cameraController; // Gunakan nullable CameraController
  bool _cameraInitialized = false;

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
    _memberDetail = MemberController().fetchMemberDetail(widget.memberId);

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

    _initializeCamera();
  }



  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _cameraController = CameraController(
      firstCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _cameraController.initialize();
      setState(() {
        _cameraInitialized = true;
      });
    } catch (e) {
      // print('Error initializing camera: $e');
    }
  }

// @override
// void dispose() {
//   _cameraController.dispose(); // Menghentikan dan me-"dispose" kamera
//   super.dispose();
// }
  // @override
  // void dispose() {
  //   _httpClient.close();
  //   if (_cameraInitialized) {
  //     _cameraController.dispose();
  //   }
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return DraggableHome(
      leading: const Icon(Icons.arrow_back_ios),
      title: const Text("Detail"),
      actions: [
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TakePictureScreen(
                  cameraController: _cameraController!,
                ),
              ),
            );
          },
          icon: const Icon(Icons.camera_alt),
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
      children: const [
        Icon(
          Icons.camera_alt,
          color: Colors.white,
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
                  color: Colors.white),
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
              border: myinputborder(),
              enabledBorder: myinputborder(),
              focusedBorder: myfocusborder(),
              hintText: 'Enter $label',
            ),
          ),
          SizedBox(height: 16.0),
        ],
      ),
    );
  }

  OutlineInputBorder myinputborder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: Colors.blue,
        width: 2,
      ),
    );
  }

  OutlineInputBorder myfocusborder() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(20)),
      borderSide: BorderSide(
        color: Colors.lightBlueAccent,
        width: 2,
      ),
    );
  }
}
