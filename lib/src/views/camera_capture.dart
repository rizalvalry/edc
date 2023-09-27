import 'dart:convert';
import 'dart:io';
import 'package:app_dart/src/config/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ImageUpload extends StatefulWidget {
  final String memberId;

  ImageUpload({required this.memberId});

  @override
  State<StatefulWidget> createState() {
    return _ImageUploadState();
  }
}

class _ImageUploadState extends State<ImageUpload> {
  File? capturedImage; // Gambar yang diambil dari kamera
  File? uploadimage; // Gambar yang dipilih dari galeri
  bool isImageSelected = false;

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
  String uploadurl = "http://192.168.18.103/wartelsus/members/updateImageProperti";
  
  try {
    List<int> imageBytes = imageToUpload.readAsBytesSync();
    String baseImage = base64Encode(imageBytes);

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
        print(jsondata["msg"]);
      } else {
        print("Upload berhasil");
      }
    } else {
      print("Error selama koneksi ke server");
    }
  } catch (e) {
    print("Error selama konversi ke Base64: $e");
  }
}


  // Future<void> uploadImage(File imageToUpload) async {
  //   String memberId = widget.memberId; // Mendapatkan memberId dari widget
  //   String fileName =
  //       "CAPTURE$memberId.png"; // Nama file sesuai dengan memberId
  //   String uploadurl = "http://192.168.18.106/test/image_upload.php";

  //   try {
  //     List<int> imageBytes = imageToUpload.readAsBytesSync();
  //     String baseimage = base64Encode(imageBytes);

  //     var response = await http.post(
  //       Uri.parse(uploadurl),
  //       body: {
  //         'image': baseimage,
  //         'memberId': memberId, // Menambahkan memberId sebagai parameter
  //         'fileName': fileName, // Menambahkan fileName sebagai parameter
  //       },
  //     );

  //     if (response.statusCode == 200) {
  //       var jsondata = json.decode(response.body);
  //       if (jsondata["error"]) {
  //         print(jsondata["msg"]);
  //       } else {
  //         print("Upload berhasil");
  //       }
  //     } else {
  //       print("Error selama koneksi ke server");
  //     }
  //   } catch (e) {
  //     print("Error selama konversi ke Base64");
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColor.baseColor,
        title: Text("Upload Image to Server"),
      ),
      body: Container(
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
              child: uploadimage == null || isImageSelected == null
                  ? Container()
                  : ElevatedButton.icon(
                      onPressed: () {
                        uploadImage(uploadimage!, widget.memberId);
                      },
                      icon: Icon(Icons.file_upload),
                      label: Text("UPLOAD IMAGE"),
                    ),
            ),
            Container(
              child: ElevatedButton.icon(
                onPressed: () {
                  chooseImage();
                },
                icon: Icon(Icons.image),
                label: Text("Choose Image"),
              ),
            ),
            Container(
              child: ElevatedButton.icon(
                onPressed: () {
                  captureImageAndUpload();
                },
                icon: Icon(Icons.camera_alt),
                label: Text("Capture IMAGE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
