import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/postlocation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

class PostPage extends StatefulWidget {
  const PostPage({Key? key}) : super(key: key);

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Map<String, dynamic>> _images = [];
  List<Map<String, dynamic>> aramaimages = [];

  bool _loading = true;
  String kullanAdi = "";
  String balikAdi = "";
  String mekanAdi = "";
  TextEditingController _yorumController = TextEditingController();
  List<String> begeniler = [];
  String docId = "";

  @override
  void initState() {
    super.initState();
    _getBegeniler();
    _getImages();
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : _buildImageList();
  }

  Widget _buildImageList() {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/balik.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => balikAdi = value,
                    decoration: const InputDecoration(
                        labelText: 'Balık Türü Giriniz',
                        border: OutlineInputBorder(),
                        enabledBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                              color: Colors
                                  .white), // Focused border rengini kırmızı yapar
                        ),
                        labelStyle: TextStyle(color: Colors.white),
                        hintStyle: TextStyle(color: Colors.white)),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    aranangetir(balikAdi, mekanAdi);
                    // Arama metodu buraya gelecek
                    // Örnek:
                    // yönlendirmeMetodu();
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Colors.white),
                    onChanged: (value) => mekanAdi = value,
                    decoration: const InputDecoration(
                      labelText: 'Mekan Ara',
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      enabledBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .white), // Focused border rengini kırmızı yapar
                      ),
                      labelStyle: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    aranangetir(balikAdi, mekanAdi);
                    // Arama metodu buraya gelecek
                    // Örnek:
                    // yönlendirmeMetodu();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _images.length,
              itemBuilder: (context, index) {
                return _buildPostCard(_images[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  String zamanFarkiHesapla(int microsecondsSinceEpoch) {
    DateTime gecenZaman =
        DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);
    Duration fark = DateTime.now().difference(gecenZaman);

    if (fark.inDays > 0) {
      return '${fark.inDays} gün önce';
    } else if (fark.inHours > 0) {
      return '${fark.inHours} saat önce';
    } else if (fark.inMinutes > 0) {
      return '${fark.inMinutes} dakika önce';
    } else {
      return '${fark.inSeconds} saniye önce';
    }
  }

  Widget _buildPostCard(Map<String, dynamic> imageData) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(imageData['profil_foto']),
            ),
            title: const Text('Kullanıcı Adı'),
            subtitle: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(imageData['kullanici_adi'].toString()),
                Text(zamanFarkiHesapla(imageData['tarih']))
              ],
            ),
          ),
          CachedNetworkImage(
            imageUrl: imageData['foto_url'],
            placeholder: (context, url) => Container(), // Placeholder ekleyin
            errorWidget: (context, url, error) =>
                Icon(Icons.error), // Hata durumunda gösterilecek widget
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  try {
                    if (begeniler.contains(imageData["id"])) {
                      _firestore
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('begendiklerim')
                          .doc(docId)
                          .update({
                        'fotolar': FieldValue.arrayRemove([imageData["id"]])
                      });
                      setState(() {
                        begeniler.remove(imageData["id"]);
                      });
                    } else {
                      _firestore
                          .collection('users')
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .collection('begendiklerim')
                          .doc(docId)
                          .update({
                        'fotolar': FieldValue.arrayUnion([imageData["id"]])
                      });
                      setState(() {
                        begeniler.add(imageData["id"]);
                      });
                    }
                  } catch (e) {
                    debugPrint('Hata: $e');
                  }

                  // Beğeni butonu işlevselliği
                },
                icon: Icon(Icons.favorite,
                    color: begeniler.contains(imageData["id"])
                        ? Colors.red
                        : Colors.grey),
              ),
              IconButton(
                onPressed: () async {
                  try {
                    debugPrint(imageData.toString());
                    QuerySnapshot querySnapshot =
                        await _firestore.collection('users').get();
                    for (QueryDocumentSnapshot doc in querySnapshot.docs) {
                      String userId = doc.id;
                      QuerySnapshot imageSnapshot = await _firestore
                          .collection('users')
                          .doc(userId)
                          .collection('fotograflarim')
                          .orderBy('tarih', descending: true)
                          .get();
                      for (QueryDocumentSnapshot imageDoc
                          in imageSnapshot.docs) {
                        String imageId = imageDoc["id"]
                            .toString(); // imageData['id'] ifadesi burada düzeltilmiştir.
                        String imageDataId = imageData['id'].toString();
                        // debugPrint(imageId);
                        // debugPrint(imageDataId);
                        if (imageId == imageDataId) {
                          debugPrint(imageData["yorumlar"].toString());
                        }
                        //debugPrint(imageDoc["yorumlar"].toString());
                      }
                    }
                  } catch (e) {
                    print('Hata: $e');
                  }
                  if (context.mounted) {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Yorumlar',
                                style: Theme.of(context).textTheme.headline6,
                              ),
                              const SizedBox(height: 16.0),
                              imageData["yorumlar"].isEmpty
                                  ? Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Text(
                                        "Bu fotoğrafa yorum yazan ilk kişi siz olun",
                                        style: TextStyle(
                                            fontStyle: FontStyle.italic),
                                      ),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: imageData["yorumlar"].length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        var yorum =
                                            imageData["yorumlar"][index];
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Row(
                                            children: [
                                              Text(
                                                yorum["kullanici_adi"] + ":",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 20),
                                              ),
                                              const SizedBox(width: 8.0),
                                              Text(
                                                yorum["yorum"],
                                                style: TextStyle(fontSize: 20),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(height: 16.0),
                              TextField(
                                controller: _yorumController,
                                decoration: const InputDecoration(
                                  labelText: 'Yorumunuzu girin',
                                ),
                              ),
                              const SizedBox(height: 16.0),
                              GestureDetector(
                                  onTap: () async {
                                    String kulAdi = FirebaseFirestore.instance
                                        .collection("users")
                                        .doc(FirebaseAuth
                                            .instance.currentUser!.uid)
                                        .get()
                                        .toString();
                                    debugPrint(imageData["kullanici_adi"]);
                                    String yorum = _yorumController.text;
                                    _firestore
                                        .collection('users')
                                        .doc(imageData["userId"])
                                        .collection('fotograflarim')
                                        .doc(imageData["id"])
                                        .update({
                                      "yorumlar": FieldValue.arrayUnion([
                                        {
                                          "kullanici_adi": kullanAdi,
                                          "yorum": yorum
                                        }
                                      ])
                                    });
                                    setState(() {
                                      _yorumController.text = "";
                                      imageData["yorumlar"].add({
                                        "kullanici_adi": kullanAdi,
                                        "yorum": yorum
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(8.0),
                                      color: Colors.deepPurpleAccent,
                                      child: Text(
                                        'Yorum Yap',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  )),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  // Yorum butonu işlevselliği
                },
                icon: Icon(Icons.comment),
              ),
              IconButton(
                onPressed: () async {
                  // Konum butonu işlevselliği
                  GeoPoint point = imageData["nerede"];
                  int balik_adet = imageData["balik_adet"];
                  String balik_turu = imageData["balik_turu"];
                  double latitude = point.latitude;
                  double longitude = point.longitude;

                  // Konumun adını al
                  // String locationName =
                  //     await _getLocationName(latitude, longitude);

                  // Google Maps URL oluştur
                  // final String googleMapsUrl =
                  //     'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

                  // // Google Maps uygulamasını aç
                  // if (await canLaunch(googleMapsUrl)) {
                  //   await launch(googleMapsUrl);
                  // } else {
                  //   throw 'Google Maps uygulaması açılamadı.';
                  // }
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return PostLocation(
                      latitude: latitude,
                      longitude: longitude,
                      balik_adet: balik_adet,
                      balik_turu: balik_turu,
                    );
                  }));
                },
                icon: Icon(Icons.location_on),
              ),
            ],
          ),
          imageData["kullanici_yorumu"] == ""
              ? Container(
                  child: Text("Kullanıcı yorum yapmamış"),
                )
              : Column(
                  children: [
                    Text(
                      "Kullanıcı Yorumu:",
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    ListTile(title: Text(imageData["kullanici_yorumu"])),
                  ],
                )
        ],
      ),
    );
  }

  Future<String> _getLocationName(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        return placemarks[0].name ?? 'Belirsiz';
      } else {
        return 'Belirsiz';
      }
    } catch (e) {
      print('Hata: $e');
      return 'Belirsiz';
    }
  }

  Future<void> _getImages() async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('users').get();
      await FirebaseFirestore.instance
          .collection("users")
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get()
          .then((value) {
        kullanAdi = value.get("userName");
      });
      debugPrint(kullanAdi);
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String userId = doc.id;
        QuerySnapshot imageSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('fotograflarim')
            .orderBy('tarih', descending: true)
            .get();
        for (QueryDocumentSnapshot imageDoc in imageSnapshot.docs) {
          imageDoc.id;
          String url = imageDoc['foto_url'];
          int date = imageDoc['tarih'];
          String kullanici_adi = imageDoc['kullanici_adi'];
          GeoPoint nerde = imageDoc['nerede'];
          String profil_foto = imageDoc['profil_foto'];
          String id = imageDoc["id"].toString();
          String UserId = imageDoc["userId"];
          String balikturu = imageDoc["balik_turu"];
          String balik_tanim = imageDoc["balik_tanim"];

          _images.add({
            'userId': userId,
            'foto_url': url,
            'profil_foto': profil_foto,
            'tarih': date,
            'kullanici_adi': kullanici_adi,
            'balik_turu': balikturu,
            'balik_tanim': balik_tanim,
            'nerede': nerde,
            'kullanici_yorumu': imageDoc["kullanici_yorumu"] ?? "Yorum Yok",
            'id': id,
            'balik_adet': imageDoc["balik_adet"],
            "yorumlar": imageDoc["yorumlar"] ?? "Yorum Yok"
          });
          aramaimages.add({
            'userId': userId,
            'foto_url': url,
            'profil_foto': profil_foto,
            'tarih': date,
            'kullanici_adi': kullanici_adi,
            'balik_turu': balikturu,
            'kullanici_yorumu': imageDoc["kullanici_yorumu"] ?? "Yorum Yok",
            'balik_tanim': balik_tanim,
            'nerede': nerde,
            'id': id,
            'balik_adet': imageDoc["balik_adet"],
            "yorumlar": imageDoc["yorumlar"] ?? "Yorum Yok"
          });
        }
        _images.sort((a, b) => b['tarih'].compareTo(a['tarih']));
        aramaimages.sort((a, b) => b['tarih'].compareTo(a['tarih']));
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      print('Hata: $e');
    }
  }

  void _getBegeniler() {
    String userId = FirebaseAuth.instance.currentUser!.uid;
    docId = userId;

    // Kullanıcının UID'sini kullanarak belge oluştur
    _firestore
        .collection('users')
        .doc(userId)
        .collection('begendiklerim')
        .doc(userId)
        .get() // Belgeyi al
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        // Belge varsa, fotolar alanındaki verileri al
        List<dynamic> fotolar = docSnapshot.data()?['fotolar'] ?? [];

        // fotolar listesine ekle
        fotolar.forEach((begeni) {
          begeniler.add(begeni.toString());
        });
      } else {
        // Belge yoksa, boş bir fotolar listesiyle belge oluştur
        _firestore
            .collection('users')
            .doc(userId)
            .collection('begendiklerim')
            .doc(userId)
            .set({'fotolar': []}) // Boş bir fotolar listesi ile belge oluştur
            .then((_) {
          print('Kullanıcı belgesi başarıyla oluşturuldu.');
        }).catchError((error) {
          print('Belge oluşturma hatası: $error');
        });
      }
    }).catchError((error) {
      print('Belge alma hatası: $error');
    });
  }

  void aranangetir(String balikAdi, String mekanadi) {
    if (mekanAdi != "" && balikAdi != "") {
      _images = aramaimages;
      List<Map<String, dynamic>> _images2 = [];
      for (var i = 0; i < _images.length; i++) {
        if (_images[i]["balik_turu"] == balikAdi &&
            _images[i]["balik_tanim"] == mekanAdi) {
          _images2.add(_images[i]);
        }
      }
      setState(() {
        _images = _images2;
      });
    } else if (mekanAdi == "" && balikAdi == "") {
      setState(() {
        _images = aramaimages;
      });
    } else if (mekanAdi != "" && balikAdi == "") {
      _images = aramaimages;
      List<Map<String, dynamic>> _images2 = [];
      for (var i = 0; i < _images.length; i++) {
        if (_images[i]["balik_tanim"] == mekanAdi) {
          _images2.add(_images[i]);
        }
      }
      setState(() {
        _images = _images2;
      });
    } else if (balikAdi != "" && mekanAdi == "") {
      _images = aramaimages;
      List<Map<String, dynamic>> _images2 = [];
      for (var i = 0; i < _images.length; i++) {
        if (_images[i]["balik_turu"] == balikAdi) {
          _images2.add(_images[i]);
        }
      }
      setState(() {
        _images = _images2;
      });
    } else {
      _images = aramaimages;
    }
  }
}
