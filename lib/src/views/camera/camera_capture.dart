// ignore_for_file: avoid_unnecessary_containers

import 'dart:convert';
import 'dart:io';
import 'package:app_dart/src/config/app_color.dart';
import 'package:app_dart/src/config/base_url.dart';
import 'package:app_dart/src/controllers/member_controller.dart';
import 'package:app_dart/src/views/member/member_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  final String memberId;
  final bool showSkipButton;

  // ignore: use_key_in_widget_constructors
  const ImageUpload({required this.memberId, this.showSkipButton = false});

  @override
  State<StatefulWidget> createState() {
    return _ImageUploadState();
  }
}

class _ImageUploadState extends State<ImageUpload> {
  File? capturedImage; // Gambar yang diambil dari kamera
  File? uploadimage; // Gambar yang dipilih dari galeri
  bool isImageSelected = false;
  final MemberController _controller = MemberController();
  bool isLoading = false;
  bool isUploadComplete = false;

  Future<void> chooseImage() async {
    var imagePicker = ImagePicker();
    var pickedImage = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        uploadimage = File(pickedImage.path);
        isImageSelected =
            true; // Setelah gambar dipilih, atur isImageSelected menjadi true
      });
    }
  }

  Future<void> captureImageAndUpload() async {
    var imagePicker = ImagePicker();
    var capturedImageFile =
        await imagePicker.pickImage(source: ImageSource.camera);
    if (capturedImageFile != null) {
      setState(() {
        capturedImage = File(capturedImageFile.path);
        isImageSelected =
            true; // Setelah gambar diambil dari kamera, atur isImageSelected menjadi true
      });

      // Panggil metode untuk mengunggah gambar setelah diambil
      await uploadImage(capturedImage!, widget.memberId);
    }
  }

  Future<void> uploadImage(File imageToUpload, String memberId) async {
    try {
      setState(() {
        isLoading = true;
      });
      List<int> imageBytes = imageToUpload.readAsBytesSync();
      String baseImage = base64Encode(imageBytes);

      final baseUrl = BaseUrl();

      String uploadurl = baseUrl.captureCameraAction();

      var response = await http.post(
        Uri.parse(uploadurl),
        body: {
          'Id': memberId,
          'photo': baseImage,
        },
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata["error"]) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(jsondata["msg"]),
              duration: Duration(
                  seconds: 2), // Sesuaikan durasi Snackbar sesuai keinginan
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Upload berhasil"),
              duration: Duration(
                  seconds: 2), // Sesuaikan durasi Snackbar sesuai keinginan
            ),
          );
          // Gambar berhasil diunggah, mungkin Anda ingin melakukan sesuatu di sini
          setState(() {
            isUploadComplete =
                true; // Setelah berhasil upload, atur isUploadComplete menjadi true
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error selama koneksi ke server"),
            duration: Duration(
                seconds: 2), // Sesuaikan durasi Snackbar sesuai keinginan
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Upload Berhasil"),
          duration: Duration(
              seconds: 2), // Sesuaikan durasi Snackbar sesuai keinginan
        ),
      );
      setState(() {
        isUploadComplete =
            true; // Setelah berhasil upload, atur isUploadComplete menjadi true
      });
    } finally {
      setState(() {
        isLoading =
            false; // Mengatur isLoading menjadi false setelah pengambilan gambar selesai
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dapatkan ukuran layar perangkat
    Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.baseColor,
        title: Text(
          "Upload Image to Server",
          style: TextStyle(color: AppColor.baseColor),
        ),
        leading: IconButton(
          // ignore: prefer_const_constructors
          icon: Icon(Icons.arrow_back_ios, color: AppColor.darkOrange),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Stack(
        children: <Widget>[
          Container(
            width: screenSize.width,
            height: screenSize.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/blue-wallpaper.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            height: 300,
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  child: isImageSelected &&
                          (uploadimage != null || capturedImage != null)
                      ? SizedBox(
                          height: 150,
                          child: Image.file(uploadimage ?? capturedImage!),
                        )
                      : Container(),
                ),
                Container(
                  // ignore: unnecessary_null_comparison
                  child: uploadimage == null || isImageSelected == null
                      ? Container()
                      : ElevatedButton.icon(
                          onPressed: () {
                            uploadImage(uploadimage!, widget.memberId);
                          },
                          // ignore: prefer_const_constructors
                          icon: Icon(Icons.file_upload),
                          // ignore: prefer_const_constructors
                          label: isLoading
                              ? const CircularProgressIndicator(
                                  // Tampilkan loading indicator saat isLoading adalah true
                                  color: AppColor.darkOrange,
                                )
                              : Text("UPLOAD IMAGE"),
                        ),
                ),
                // Container(
                //   child: ElevatedButton.icon(
                //     onPressed: () {
                //       chooseImage();
                //     },
                //     icon: const Icon(Icons.image),
                //     label: const Text("Choose Image"),
                //   ),
                // ),
                Container(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      captureImageAndUpload();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all<Color>(AppColor.baseColor),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      elevation: MaterialStateProperty.all<double>(
                          8.0), // Atur tinggi shadow sesuai keinginan
                      shadowColor:
                          MaterialStateProperty.all<Color>(Colors.black),
                      minimumSize: MaterialStateProperty.all<Size>(
                        // ignore: prefer_const_constructors
                        Size(200.0, 50.0),
                      ),
                    ),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text("Capture IMAGE"),
                  ),
                ),
              ],
            ),
          ),
          if (widget.showSkipButton || isUploadComplete == true)
            Padding(
              padding: EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => MemberListScreen(
                          members: _controller.fetchMembers(
                              sort: 'LEVE_MEMBERNAME', dir: 'ASC'),
                          currentSort: 'ASC',
                        ),
                      ),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        isUploadComplete
                            ? AppColor.baseColor
                            : AppColor.dangerColor),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    elevation: MaterialStateProperty.all<double>(8.0),
                    shadowColor: MaterialStateProperty.all<Color>(Colors.black),
                    minimumSize: MaterialStateProperty.all<Size>(
                      const Size(200.0, 50.0),
                    ),
                  ),
                  icon: isLoading
                      ? const CircularProgressIndicator(
                          // Tampilkan loading indicator saat isLoading adalah true
                          color: AppColor.darkOrange,
                        )
                      : Icon(Icons.done_all),
                  label: Text(
                    isUploadComplete ? "Selesai" : "Lewati",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
