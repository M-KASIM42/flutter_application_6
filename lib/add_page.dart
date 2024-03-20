import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  File? file;
  var _recognitions;
  var v = "";
  // var dataList = [];
  @override
  void initState() {
    super.initState();
    loadmodel().then((value) {
      setState(() {});
    });

    debugPrint("init State userId${FirebaseAuth.instance.currentUser!.uid}");
  }

  loadmodel() async {
    await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future<void> _pickImage2() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      setState(() {
        _image = image;
        file = File(image!.path);
      });
      detectimage(file!);
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  Future detectimage(File image) async {
    int startTime = new DateTime.now().millisecondsSinceEpoch;
    var recognitions = await Tflite.runModelOnImage(
      path: image.path,
      numResults: 6,
      threshold: 0.05,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    setState(() {
      _recognitions = recognitions;
      v = recognitions.toString();
      // dataList = List<Map<String, dynamic>>.from(jsonDecode(v));
    });
    print("//////////////////////////////////////////////////");
    print(_recognitions);
    // print(dataList);
    print("//////////////////////////////////////////////////");
    int endTime = new DateTime.now().millisecondsSinceEpoch;
    print("Inference took ${endTime - startTime}ms");
  }

  int degis = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    degis == 0 ? Colors.deepPurpleAccent : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  degis = 0;
                });
              },
              child: Text("Foto sorgula"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    degis == 1 ? Colors.deepPurpleAccent : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  degis = 1;
                });
              },
              child: Text("Fotoğraf yükle"),
            )
          ],
        ),
        degis == 0 ? fotosorgula() : fotoyukle(),
      ],
    );
  }

  Widget fotosorgula() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          if (_image != null)
            Image.file(
              File(_image!.path),
              height: 200,
              width: 200,
              fit: BoxFit.cover,
            )
          else
            Text('No image selected'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Pick Image from Gallery'),
          ),
          ElevatedButton(
            onPressed: _pickImage2,
            child: Text('Pick Image from Camera'),
          ),
          SizedBox(height: 20),
          Text(v),
        ],
      ),
    );
  }

  Widget fotoyukle() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        if (_image != null)
          Image.file(
            File(_image!.path),
            height: 200,
            width: 200,
            fit: BoxFit.cover,
          )
        else
          Text('No image selected'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Pick Image from Gallery'),
        ),
        ElevatedButton(
          onPressed: _pickImage2,
          child: Text('Pick Image from Camera'),
        ),
        SizedBox(height: 20),
        Text(v),
        ElevatedButton(
          onPressed: () async {
            Reference ref = FirebaseStorage.instance
                .ref()
                .child("fotograflar")
                .child("${FirebaseAuth.instance.currentUser!.uid}")
                .child("${DateTime.now().microsecondsSinceEpoch}.jpg");
            try {
              await ref.putFile(File(_image!.path));
            } catch (e) {
              debugPrint("Hata: $e");
            }
            String FotoUrl = await ref.getDownloadURL();
            DocumentSnapshot docref = await FirebaseFirestore.instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .get();
            String kullaniciAdi = docref.get("userName");
            String profilFoto = docref.get("profilfoto");
            GeoPoint point = const GeoPoint(41.575465, 36.080651);
            final DocumentReference documentReference = await FirebaseFirestore
                .instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("fotograflarim")
                .add({
              "userId" : FirebaseAuth.instance.currentUser!.uid,
              "balik_adet": 0,
              "balik_turu": "a",
              "balik_tanim": "a",
              "begeni_sayisi": 0,
              "foto_url": FotoUrl,
              "profil_foto": profilFoto,
              "kullanici_adi": kullaniciAdi,
              "tarih": DateTime.now().microsecondsSinceEpoch,
              "nerede": point,
              "yorumlar": [
                {"kullanici_adi": "sami", "yorum": "sami yorum"}
              ],
            });
            if (documentReference.id != null) {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .collection("fotograflarim")
                  .doc(documentReference.id)
                  .update({"id": documentReference.id});
              Fluttertoast.showToast(
                  msg: "Fotoğraf başarıyla yüklendi",
                  toastLength: Toast.LENGTH_LONG);
              setState(() {
                v = "";
                _image = null;
                file = null;
              });
            }
          },
          child: Text("Kaydet"),
        ),
      ],
    );
  }
}
