import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FotograflarimPage extends StatefulWidget {
  const FotograflarimPage({Key? key}) : super(key: key);

  @override
  State<FotograflarimPage> createState() => _FotograflarimPageState();
}

class _FotograflarimPageState extends State<FotograflarimPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Oturum açmış kullanıcının UID'si
  late String uid; // Kullanıcının UID'sini buraya atayın

  // Kullanıcının fotoğraflarını tutacak liste
  List<DocumentSnapshot> userPhotos = [];

  // Veritabanından kullanıcının fotoğraflarını getiren fonksiyon
  Future<void> getUserPhotos() async {
    try {
      QuerySnapshot photosQuery = await _firestore
          .collection('users')
          .doc(uid)
          .collection('fotograflarim')
          .get();
      setState(() {
        userPhotos = photosQuery.docs;
      });
    } catch (error) {
      print('Fotoğrafları alma sırasında hata oluştu: $error');
    }
  }

  // Belgeyi silen fonksiyon
  Future<void> deletePhoto(String photoId) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection("fotograflarim")
          .doc(photoId)
          .delete();
      // Kullanıcıya başarıyla silindiğine dair bilgi ver
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğraf başarıyla silindi.'),
          backgroundColor: Colors.green,
        ),
      );
      // Fotoğrafları yeniden yükle
      getUserPhotos();
    } catch (error) {
      // Hata durumunda kullanıcıyı bilgilendir
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fotoğrafı silerken bir hata oluştu: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Fotoğraf silme işlemini onaylayan iletişim kutusu
  Future<void> _showDeleteConfirmationDialog(String photoId) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Fotoğrafı Sil"),
          content: Text("Seçili fotoğrafı silmek istediğinize emin misiniz?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // İptal et
              },
              child: Text("İptal"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // İptal et
                // Fotoğrafı silme fonksiyonunu çağır
                deletePhoto(photoId);
              },
              child: Text("Evet, Sil"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser!.uid;
    getUserPhotos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fotograflarim'),
      ),
      body: userPhotos.isEmpty
          ? Center(
              child: Text('Henüz fotoğrafınız yok.'),
            )
          : ListView.builder(
              itemCount: userPhotos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Image.network(
                    userPhotos[index]['foto_url'],
                    fit: BoxFit.fitWidth,
                    height: 200,
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Silme işlemini onaylamak için iletişim kutusunu göster
                          _showDeleteConfirmationDialog(userPhotos[index].id);
                        },
                        child: Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
