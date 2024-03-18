import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
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

  @override
  void initState() {
    super.initState();
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
            errorWidget: (context, url, error) => Icon(Icons.error), // Hata durumunda gösterilecek widget
          ),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  // Beğeni butonu işlevselliği
                },
                icon: const Icon(Icons.favorite),
              ),
              IconButton(
                onPressed: () {
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
                  String locationName = await _getLocationName(latitude, longitude);

                  // Google Maps URL oluştur
                  final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';

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
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
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
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        String userId = doc.id;
        QuerySnapshot imageSnapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('fotograflarim')
            .orderBy('tarih', descending: true)
            .get();
        for (QueryDocumentSnapshot imageDoc in imageSnapshot.docs) {
          String url = imageDoc['foto_url'];
          int date = imageDoc['tarih'];
          String kullanici_adi = imageDoc['kullanici_adi'];
          GeoPoint nerde = imageDoc['nerede'];
          String profil_foto = imageDoc['profil_foto'];

          _images.add({
            'foto_url': url,
            'profil_foto': profil_foto,
            'tarih': date,
            'kullanici_adi': kullanici_adi,
            'nerede': nerde,
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
}
