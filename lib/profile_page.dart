import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  void initState() {
    debugPrint("initState çalıştı");
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    debugPrint("getUserInfo çalıştı");
    Map<String, dynamic>? userInfo = await getCurrentUserInformation();
    if (userInfo != null) {
      setState(() {
        userInformation = userInfo;
        debugPrint(userInfo.toString());
      });
    } else {
      // Kullanıcı bilgisi alınamadı
    }
  }

  Map<String, dynamic>? userInformation = {};
  Future<Map<String, dynamic>?> getCurrentUserInformation() async {
    debugPrint("getCurrentUserInformation çalıştı");
    // Oturum açmış kullanıcının bilgilerini almak için FirebaseAuth kullanılır
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      debugPrint(user.uid.toString());
      // FirebaseAuth ile kullanıcının UID'sini alırız
      String userId = user.uid;

      try {
        // Firestore üzerindeki users koleksiyonundan oturum açmış kullanıcının bilgilerini almak için
        // kullanıcının UID'sini kullanarak sorgu yaparız
        DocumentSnapshot<Map<String, dynamic>> userData =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(userId)
                .get();

        debugPrint(userData["email"].toString());
        if (userData.exists) {
          // Kullanıcıya ait veri varsa dökümanı Map olarak döndürürüz
          return userData.data();
        } else {
          // Kullanıcıya ait veri yoksa null döndürürüz
          return null;
        }
      } catch (e) {
        // Hata durumunda null döndürürüz
        debugPrint("Kullanıcı bilgileri alınamadı: $e");
        return null;
      }
    } else {
      // Oturum açmış bir kullanıcı yoksa null döndürürüz
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("build çalıştı");
    return SafeArea(
      child: Scaffold(
          body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 500,
              width: double.infinity,
              child: Column(
                children: [
                  const SizedBox(
                    height: 50,
                  ),
                  GestureDetector(
                    onTap: () async {
                      final picker = await ImagePicker()
                          .pickImage(source: ImageSource.gallery);
                      String fileName =
                          "${FirebaseAuth.instance.currentUser!.uid}.jpg";
                      Reference ref = FirebaseStorage.instance
                          .ref()
                          .child("profilfoto")
                          .child(fileName);
                      try {
                        await ref.putFile(File(picker!.path));
                      } catch (e) {
                        debugPrint("Hata: $e");
                      }
                      String profilFotoUrl = await ref.getDownloadURL();
                      await FirebaseFirestore.instance
                          .collection("users")
                          .doc(FirebaseAuth.instance.currentUser!.uid)
                          .update({"profilfoto": profilFotoUrl});
                      setState(() {
                        userInformation!["profilfoto"] = profilFotoUrl;
                      });
                    },
                    child: CircleAvatar(
                      radius: 100,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: userInformation!['profilfoto'] != null
                                ? NetworkImage(
                                    userInformation!['profilfoto'].toString())
                                : const NetworkImage(
                                    "data:image/png;base64,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"),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                                Colors.black.withOpacity(0.5),
                                BlendMode.darken),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "E-Mail",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(userInformation!["email"] ?? "E-Mail Bulunamadı",
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(
                    height: 15,
                  ),
                  const Text(
                    "Kullanıcı Adı",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Text(
                      userInformation!["userName"] ??
                          "Kullanıcı Adı Bulunamadı",
                      style: const TextStyle(fontSize: 15)),
                ],
              ),
            ),
          ],
        ),
      )),
    );
  }
}
