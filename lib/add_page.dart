import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'main_page.dart';

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
  final TextEditingController _nerdeController = TextEditingController();
  final TextEditingController _adetController = TextEditingController();
  final TextEditingController _kullaniciyorumuController = TextEditingController();
  double latidute = 0.0;
  double longitude = 0.0;
  int _currentStep = 0;
final List<Map<String, dynamic>> dataList = [
  {"id": 0, "name": "alabalik", "detay": "Alabalık, Salmonidae familyasının en tanınmış üyesidir ve somon balığı ile yakın akrabadır. Alabalık diye adlandırdığımız balıkların bazıları Salmo cinsine ait değillerdir. Salmonidae ailesinin arta kalanını oluşturan Oncorhynchus ve Salvelinus cinslerine ait olan balıkların bazılarına da alabalık denilir."},
  {"id": 1, "name": "aslanbaligi", "detay": "Aslan balığı, Hint Okyanusu ve Büyük Okyanus'un batı kısımlarında, Kızıldenizde, mercan kayalıklarda yaşayan zehirli deniz balıklarından oluşan bir cinstir. İnsanlar için tehlike teşkil ederler. Kıyıya yakın yerler ile 50 metre derinlik arasındaki kısımlarda yaşarlar. Yetişkinleri 40 cm uzunluğa değin erişebilirler."},
  {"id": 2, "name": "balonbaligi", "detay": "Balon balığı veya Sennin-fugu olarak bilinen Lagocephalus sceleratus, Tetraodontidae familyasından son derece zehirli bir kemikli deniz balığıdır."},
  {"id": 3, "name": "barbun", "detay": "Vücut yanlardan basık, oval şekilde baş irice yandan görünüşü buruna doğru yuvarlak, alnı dikey, yüzgeçleri sarı, vücudu pembe-kırmızı, baş, vücut büyük, kolayca dökülebilen pullarla kaplı, alt çenenin altında uzunca iki bıyığı vardır. Alt çenede diş yoktur. Yan çizgisi aralıksız ve düzdür. Dorsal yüzgeç renksiz veya düz renklidir."},
  {"id": 5, "name": "hamsi", "detay": "Sürüler halinde yaşar ve 18 cm'e kadar büyür. Ocak - Mart arasında beslenmek için sahillere yaklaşır. Gündüzleri 30–40 m. derinlerde, geceleri yüzeye yakınlarda dolaşır. 1 yaşından itibaren olgunluğa erişip 18°-20 °C sularda, 25–60 m. derinliklerde ve az tuzlu sularda üreyip yaklaşık 40.000 yumurta döker."},
  {"id": 6, "name": "iskorpit", "detay": "İskorpit, Scorpaenidae familyasından bir balık türü. Lipsoz balığına benzer fakat Lipsoz'a göre daha küçük ve daha koyu renklere sahiptir. İskorpitler havaların ısınmasıyla kıyı bölgelere doğru yönelirler. Özellikle Ağustos ve Eylül aylarında kıyıya yakın bölgelerde bulundukları için avlanmaları daha kolaydır. "},
  {"id": 7, "name": "istavrit", "detay": "İstavrit, Carangidae familyasından Trachurus cinsini oluşturan balık türlerine verilen ad. Birbirine çok benzeyen bu balıkların vücudu yanlardan biraz basık ve iğ biçimindedir. Ağzı öne doğru uzayabilme yeteneğinde, dişleri ince, gözleri iri, kuyruğu derin çatallıdır."},
  {"id": 8, "name": "kalkan", "detay": "Kalkan balığı, Scophthalmidae familyasına ait, gözleri vücudunun sol tarafında bulunan ve sağ tarafı ile denizin tabanında yatan bir yassı balık türü. Atlas Okyanusu'nun doğusunda kıyı yakınlarında, Akdenizde, Ege denizi'nde, Marmara denizi'nde ve Karadeniz'de, 20 ila 70 metre derinlikte yaşar."},
  {"id": 9, "name": "karides", "detay": "Karides, Avrupa denizlerinde ve Kuzey Amerika kıyılarında yaşayan, kabuklular sınıfındandır. Silindirik vücutlu, uzun duyargalıdır. Boyu 5–6 cm'dir. Vücudu kalsiyum karbonattan meydana gelen bir zırhla örtülüdür. Gövdesi eklemlidir. Geniş yüzgeçimsi kuyruğunu sallayarak geri geri yüzer."},
  {"id": 10, "name": "kefal", "detay": "Akdeniz, Ege, Marmara ve Karadeniz’de sürüler halinde yaşar. Has kefal, sidikli ilarya, altınbaş kefal, mavri gibi adları olan değişik türleri vardır. Ortalama uzunluğu cinsine göre 25 ile 90 santimetre arasındadır. Ortalama ömrü ise 15 yıldır. Çok zeki, güçlü ve çevik bir balık olan kefal avı çok zahmetlidir. Oltaya çok zor atlar. En verimi avı, serpme ağla yapılır."},
  {"id": 11, "name": "levrek", "detay": "Genellikle orta büyüklükte olan levrek, ortalama 30 ila 70 santimetre arasında uzunluğa sahiptir. Ancak daha büyük bireyler de bulunabilir. Levrek, sahip olduğu beyaz eti ile tanınır ve bu et oldukça lezzetlidir. Ağız yapısı büyüktür. Bu, levreğe avlanırken avantaj sağlar. Sırt yüzgeci oldukça belirgin ve sivri uçludur."},
  {"id": 12, "name": "lufer", "detay": "Lüfer, Pomatomidae familyasından ekonomik değeri yüksek bir balık türü. Vücutları uzun, sırt yüzgeçleri iki tane, kuyrukları çatallı, ağızları iri, dişleri sivri ve güçlüdür. Yan çizgi hemen hemen düz olup, pullarla örtülüdür. Yan çizgide pul sayısı 95-100 adettir."},
  {"id": 13, "name": "palamut", "detay": "Palamut, genellikle sıcak ve ılık denizlerde, hem açıkta hem de kıyı bölgelerinde yaşayan kemikli balık türüdür. Oldukça büyük ve keskin dişlerle kaplı olan ağzı, torpil biçimindeki bedeninin ucundadır. Sırtlarının genellikle mavimsi rengi, yanlara doğru gidildikçe karında gümüşi beyaza dönüşür."},
  {"id": 14, "name": "rina", "detay": "Dikenli vatoz veya rina, Dasyatidae familyasından, kuzeydoğu Atlas Okyanusu'na ve Akdeniz'e özgün bir balık türüdür. Madeyra ve Fas'tan Britanya Adaları'na, Norveç'in güneyinden Baltık Denizi'ne, Atlas Okyanusu'ndan Akdeniz ve Karadeniz'in tamamında yaşar."},
  {"id": 15, "name": "sazan", "detay": "Sazan, sazangiller familyasına adını veren tatlı su balığı. Göl ve yavaş akan derelerde bulunur. Uzun gövdeli, solucan, böcek larvaları ve bitkilerle beslenen bir dip balığıdır. 1,5 metre boyunda, 35 kg ağırlıkta olanları vardır. Ömrü 40-50 yıla kadar varabilir."},
  {"id": 16, "name": "tekir", "detay": "Tekir, Mullidae familyasından vücut rengi kırmızı veya pembemsi renkte olan bir balık türü. Vücut yuvarlak olup, başın altında bir çift bıyık bulunur. Büyük olan başın uzunluğu, yüksekliğinden fazladır ve baş profili eğimlidir. Birinci sırt yüzgecinde boyunca sarı ve kırmızımsı renkli bantlar bulunur."},
  {"id": 17, "name": "vatoz", "detay": "Bu tür balıklar ılık veya soğuk denizlerde yaşarlar. Birçok türü bulunan bu balıkların deniz dibindeki kum ve çamurlarda yaşadığı bilinir. Tatlı ve tuzlu sularda yaşayan bu tür balıklar, okyanuslarda sıklıkla karşılaşılır."},
];

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
      model: "assets/model_unquant2.tflite",
      labels: "assets/labels2.txt",
    );
  }

  Future<Object> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return "Location services are disabled.";
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return "Location permissions are permantly denied.";
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return "Location permissions are permantly denied.";
    }

    return await Geolocator.getCurrentPosition(
        // desiredAccuracy: LocationAccuracy.high
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
    int startTime = DateTime.now().millisecondsSinceEpoch;
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
                child: const Text("Foto sorgula"),
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
                child: const Text("Fotoğraf yükle"),
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
                child: const Text("Fotoğraf paylaş"),
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
            fit: BoxFit.fitHeight,
          )
        else
          const Text('Fotoğraf Seçilmedi'),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Galeriden Seç'),
        ),
        ElevatedButton(
          onPressed: _pickImage2,
          child:const Text('Kameradan Çek'),
        ),
        const SizedBox(height: 20),
        Text(v),
        const SizedBox(height: 20),
        v == "" ? const Text("") : Text(dataList.firstWhere((element) => element["name"] == _recognitions[0]["label"].toString().split(' ')[1].toString())["detay"]),
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
                  Object position = await _determinePosition();
                  if (position is Position) {
                    setState(() {
                      latidute = position.latitude;
                      longitude = position.longitude;
                    });
                  }
                  if (position is String) {
                    Fluttertoast.showToast(
                        msg: "Konum erişim izni verilmedi",
                        toastLength: Toast.LENGTH_LONG);
                  }
                },
                child: const Text("Konum Al"))
            : Text("Konum Alındı$latidute $longitude"),
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
          child: const Text("Kaydet"),
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
              fit: BoxFit.fitHeight,
            )
          else
            const Text('Fotoğraf seçilmedi'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Galeriden Seç'),
          ),
          ElevatedButton(
            onPressed: _pickImage2,
            child: const Text('Kameradan Çek'),
          ),
          const SizedBox(height: 20),
          Text(v),
          const SizedBox(height: 20),
          v == "" ? const Text("") : Text(dataList.firstWhere((element) => element["name"] == _recognitions[0]["label"].toString().split(' ')[1].toString())["detay"]),
        ],
      ),
    );
  }

  Widget fotopaylas() {
    return Stepper(
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        return _currentStep == 2
            ? Row(
                children: <Widget>[
                  TextButton(
                    onPressed: details.onStepContinue,
                    child: const Text('KAYDET'),
                  ),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('ÖNCEKİ'),
                  ),
                ],
              )
            : Row(
                children: <Widget>[
                  TextButton(
                    onPressed: details.onStepContinue,
                    child: const Text('SONRAKİ'),
                  ),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('ÖNCEKİ'),
                  ),
                ],
              );
      },
      currentStep: _currentStep,
      onStepContinue: () {
        setState(() {
          if (_currentStep < 3 - 1) {
            _currentStep += 1;
          } else {
            _saveData();
          }
        });
      },
      onStepCancel: () {
        setState(() {
          if (_currentStep > 0) {
            _currentStep -= 1;
          } else {
            _currentStep = 0;
          }
        });
      },
      steps: [
        Step(
          title: const Text('Fotoğraf Seç'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_image != null)
                Column(
                  children: [
                    Image.file(
                      File(_image!.path),
                      height: 200,
                      width: 200,
                      fit: BoxFit.fitHeight,
                    ),
                    const SizedBox(height: 10),
                    Text(v == "" ? "Balık Türü" : "Balık Türü: $v"),
                    const SizedBox(height: 10),
                    v == "" ? const Text("") : Text(dataList.firstWhere((element) => element["name"] == _recognitions[0]["label"].toString().split(' ')[1].toString())["detay"]),
                  ],
                )
              else
                const Text('Fotoğraf Seçilmedi'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Galeriden Seç'),
              ),
              ElevatedButton(
                onPressed: _pickImage2,
                child: const Text('Kameradan Çek'),
              ),
            ],
          ),
          isActive: _currentStep >= 0,
        ),
        Step(
          title: const Text('Konum Al'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              latidute == 0.0
                  ? ElevatedButton(
                      onPressed: () async {
                        Object position = await _determinePosition();
                        if (position is Position) {
                          setState(() {
                            latidute = position.latitude;
                            longitude = position.longitude;
                          });
                        }
                        if (position is String) {
                          Fluttertoast.showToast(
                              msg: "Konum erişim izni verilmedi",
                              toastLength: Toast.LENGTH_LONG);
                        }
                      },
                      child: Text("Konum Al"))
                  : Text("Konum Alındı$latidute $longitude"),
            ],
          ),
          isActive: _currentStep >= 1,
        ),
        Step(
          title: const Text('Detayları Gir'),
          content: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
                margin: const EdgeInsets.all(20),
                child: TextField(
                  controller: _kullaniciyorumuController,
                  decoration: InputDecoration(
                      hintText: "Yorumunuz",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10))),
                ),
              ),
              const SizedBox(height: 20),
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
            ],
          ),
          isActive: _currentStep >= 2,
        ),
      ],
    );
  }

  void _saveData() async {
    if (_image == null) {
      Fluttertoast.showToast(
          msg: "Fotoğraf seçiniz", toastLength: Toast.LENGTH_LONG);
      return;
    }
    if (latidute == 0.0 && longitude == 0.0) {
      Fluttertoast.showToast(
          msg: "Lütfen konum erişimini açınız", toastLength: Toast.LENGTH_LONG);
      return;
    }
    Reference ref = FirebaseStorage.instance
        .ref()
        .child("fotograflar")
        .child(FirebaseAuth.instance.currentUser!.uid)
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
    final DocumentReference documentReference = await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("fotograflarim")
        .add({
      "userId": FirebaseAuth.instance.currentUser!.uid,
      "balik_adet": adet,
      "balik_turu":
          _recognitions[0]["label"].toString().split(' ')[1].toString(),
      "balik_tanim": _nerdeController.text,
      "kullanici_yorumu": _kullaniciyorumuController.text,
      "begeni_sayisi": 0,
      "foto_url": FotoUrl,
      "profil_foto": profilFoto,
      "kullanici_adi": kullaniciAdi,
      "tarih": DateTime.now().microsecondsSinceEpoch,
      "nerede": point,
      "yorumlar": [],
    });
    await FirebaseFirestore.instance
        .collection("users")
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection("fotograflarim")
        .doc(documentReference.id)
        .update({"id": documentReference.id});
    Fluttertoast.showToast(
        msg: "Fotoğraf başarıyla yüklendi", toastLength: Toast.LENGTH_LONG);
    setState(() {
      v = "";
      _image = null;
      file = null;
      _nerdeController.text = "";
      _adetController.text = "";
      _kullaniciyorumuController.text = "";
    });
    if (mounted) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => const MainPage()));
    }
  }
}
