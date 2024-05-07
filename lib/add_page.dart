import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_application_6/my_api.dart';
import 'package:flutter_application_6/post_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
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
  int degis = 0;
  TextEditingController _nerdeController = TextEditingController();
  TextEditingController _adetController = TextEditingController();
  double latidute = 0.0;
  double longitude = 0.0;
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

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permantly denied. we cannot request permissions.");
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            "Location permissions are denied (actual value: $permission).");
      }
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
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
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      degis == 2 ? Colors.deepPurpleAccent : Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    degis = 2;
                  });
                },
                child: Text("Fotoğraf paylaş"),
              )
            ],
          ),
          degis == 0
              ? fotosorgula()
              : degis == 1
                  ? fotoyukle()
                  : fotopaylas()
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
          Text('Fotoğraf Seçilmedi'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Galeriden Seç'),
        ),
        ElevatedButton(
          onPressed: _pickImage2,
          child: Text('Kameradan Çek'),
        ),
        SizedBox(height: 20),
        Text(v),
        Container(
          width: 75,
          height: 50,
          margin: const EdgeInsets.all(20),
          child: TextField(
            controller: _adetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: "Adet",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ),
        latidute == 0.0
            ? ElevatedButton(
                onPressed: () async {
                  Position position = await _determinePosition();
                  setState(() {
                    latidute = position.latitude;
                    longitude = position.longitude;
                  });
                },
                child: Text("Konum Al"))
            : Text("Konum Alındı" +
                latidute.toString() +
                " " +
                longitude.toString()),
        ElevatedButton(
          onPressed: () async {
            if (file == null) {
              Fluttertoast.showToast(
                  msg: "Fotoğraf seçiniz", toastLength: Toast.LENGTH_LONG);
              return;
            }
            if (latidute == 0.0 && longitude == 0.0) {
              Fluttertoast.showToast(
                  msg: "Lütfen konum erişimini açınız",
                  toastLength: Toast.LENGTH_LONG);
              return;
            }
            Reference ref = FirebaseStorage.instance
                .ref()
                .child("balikbilgi")
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
            GeoPoint point = GeoPoint(latidute, longitude);
            int adet = int.parse(_adetController.text);
            final DocumentReference documentReference =
                await FirebaseFirestore.instance.collection("balikbilgi").add({
              "balik_adet": adet,
              "balik_turu":
                  _recognitions[0]["label"].toString().split(' ')[1].toString(),
              "foto_url": FotoUrl,
              "kullanici_adi": kullaniciAdi,
              "balik_konum": point,
            });
            if (documentReference.id != null) {
              Fluttertoast.showToast(
                  msg: "Fotoğraf başarıyla yüklendi",
                  toastLength: Toast.LENGTH_LONG);
              setState(() {
                v = "";
                _image = null;
                file = null;
                _adetController.text = "";
                latidute = 0.0;
                longitude = 0.0;
              });
            }
          },
          child: Text("Kaydet"),
        ),
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
            Text('Fotoğraf seçilmedi'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: Text('Galeriden Seç'),
          ),
          ElevatedButton(
            onPressed: _pickImage2,
            child: Text('Kameradan Çek'),
          ),
          SizedBox(height: 20),
          Text(v),
        ],
      ),
    );
  }

  Widget fotopaylas() {
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
          Text('Fotoğraf Seçilmedi'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Galeriden Seç'),
        ),
        ElevatedButton(
          onPressed: _pickImage2,
          child: Text('Kameradan Çek'),
        ),
        SizedBox(height: 20),
        Text(v),
        Container(
          margin: const EdgeInsets.all(20),
          child: TextField(
            controller: _nerdeController,
            decoration: InputDecoration(
                hintText: "Nerede tutuldu",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ),
        Container(
          width: 75,
          height: 50,
          margin: const EdgeInsets.all(20),
          child: TextField(
            controller: _adetController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
                hintText: "Adet",
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10))),
          ),
        ),
        latidute == 0.0
            ? ElevatedButton(
                onPressed: () async {
                  Position position = await _determinePosition();
                  setState(() {
                    latidute = position.latitude;
                    longitude = position.longitude;
                  });
                },
                child: Text("Konum Al"))
            : Text("Konum Alındı" +
                latidute.toString() +
                " " +
                longitude.toString()),
        ElevatedButton(
          onPressed: () async {
            if (file == null) {
              Fluttertoast.showToast(
                  msg: "Fotoğraf seçiniz", toastLength: Toast.LENGTH_LONG);
              return;
            }
            if (latidute == 0.0 && longitude == 0.0) {
              Fluttertoast.showToast(
                  msg: "Lütfen konum erişimini açınız",
                  toastLength: Toast.LENGTH_LONG);
              return;
            }
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
            GeoPoint point = GeoPoint(latidute, longitude);
            int adet = int.parse(_adetController.text);
            final DocumentReference documentReference = await FirebaseFirestore
                .instance
                .collection("users")
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection("fotograflarim")
                .add({
              "userId": FirebaseAuth.instance.currentUser!.uid,
              "balik_adet": adet,
              "balik_turu":
                  _recognitions[0]["label"].toString().split(' ')[1].toString(),
              "balik_tanim": _nerdeController.text,
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
                _nerdeController.text = "";
                _adetController.text = "";
              });
            }
          },
          child: Text("Kaydet"),
        ),
      ],
    );
  }
}
