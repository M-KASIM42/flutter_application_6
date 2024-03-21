import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  bool _loading = true;
  String kullanAdi = "";
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
    return ListView.builder(
      itemCount: _images.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_images[index]);
      },
    );
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
            subtitle: Text(imageData['kullanici_adi'].toString()),
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
                icon:  Icon(Icons.favorite,color: begeniler.contains(imageData["id"]) ? Colors.red : Colors.grey),
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
                              for (var yorum in imageData["yorumlar"])
                                Row(
                                  children: [
                                    Text(yorum["kullanici_adi"]),
                                    Text(yorum["yorum"]),
                                  ],
                                ),
                              TextField(
                                  controller: _yorumController,
                                  decoration: const InputDecoration(
                                    labelText: 'Yorumunuzu girin',
                                  )),
                              ElevatedButton(
                                  onPressed: () async{
                                    String kulAdi = FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().toString();
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
                                          "kullanici_adi":
                                              kullanAdi,
                                          "yorum": yorum
                                        }
                                      ])
                                    });
                                    setState(() {
                                      _yorumController.text = "";
                                      imageData["yorumlar"].add({
                                        "kullanici_adi":
                                            kullanAdi,
                                        "yorum": yorum
                                      });
                                      
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Center(child: Text("Yorum Yap")))
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
                  double latitude = point.latitude;
                  double longitude = point.longitude;

                  // Konumun adını al
                  String locationName =
                      await _getLocationName(latitude, longitude);

                  // Google Maps URL oluştur
                  final String googleMapsUrl =
                      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

                  // Google Maps uygulamasını aç
                  if (await canLaunch(googleMapsUrl)) {
                    await launch(googleMapsUrl);
                  } else {
                    throw 'Google Maps uygulaması açılamadı.';
                  }
                },
                icon: Icon(Icons.location_on),
              ),
            ],
          ),
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
      await FirebaseFirestore.instance.collection("users").doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) {
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

          _images.add({
            'userId' : userId,
            'foto_url': url,
            'profil_foto': profil_foto,
            'tarih': date,
            'kullanici_adi': kullanici_adi,
            'nerede': nerde,
            'id': id,
            "yorumlar": imageDoc["yorumlar"] ?? "Yorum Yok"
          });
        }
        _images.sort((a, b) => b['tarih'].compareTo(a['tarih']));
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
          })
          .catchError((error) {
            print('Belge oluşturma hatası: $error');
          });
      }
    })
    .catchError((error) {
      print('Belge alma hatası: $error');
    });
  }
}
