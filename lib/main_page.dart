import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/add_page.dart';
import 'package:flutter_application_6/hesapayarlari_page.dart';
import 'package:flutter_application_6/post_page.dart';
import 'package:flutter_application_6/where_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'fotograflarim_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int currentIndex = 0;
  List<StatefulWidget> pages = [
    const PostPage(),
    const AddPage(),
    const WherePage()
  ];
  @override
  void initState() {
    super.initState();
    getUserInfo();
  }

  Future<void> getUserInfo() async {
    Map<String, dynamic>? userInfo = await getCurrentUserInformation();
    if (userInfo != null) {
      setState(() {
        userInformation = userInfo;
      });
    } else {
      // Kullanıcı bilgisi alınamadı
    }
  }

  Map<String, dynamic>? userInformation = {};
  Future<Map<String, dynamic>?> getCurrentUserInformation() async {
    // Oturum açmış kullanıcının bilgilerini almak için FirebaseAuth kullanılır
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
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
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          animationDuration: const Duration(milliseconds: 400),
          height: 70,
          color: Colors.deepPurpleAccent,
          buttonBackgroundColor: Colors.deepPurpleAccent,
          backgroundColor: Colors.white,
          index: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          items: const [
            Icon(Icons.home),
            Icon(Icons.add),
            Icon(Icons.location_on),
          ],
        ),
        appBar: AppBar(
          title: const Text('MOBİLE APPLİCATİON'),
          centerTitle: true,
          backgroundColor: Colors.deepPurpleAccent,
        ),
        drawer: Drawer(
          width: 230,
          child: Center(
            child: Column(
              children: [
                Column(
                  children: [
                    SizedBox(
                      height: 300,
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
                                radius: 30,
                                child:
                                    userInformation!["profilfoto"].toString() !=
                                            ""
                                        ? ClipOval(
                                            child: Image.network(
                                              userInformation!["profilfoto"]
                                                  .toString(),
                                              fit: BoxFit.cover,
                                              width: 70,
                                              height: 70,
                                            ),
                                          )
                                        : const Icon(Icons.person)),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "E-Mail",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(userInformation!["email"].toString(),
                              style: const TextStyle(fontSize: 15)),
                          const SizedBox(
                            height: 15,
                          ),
                          const Text(
                            "Kullanıcı Adı",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Text(userInformation!["userName"].toString(),
                              style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Divider(color: Colors.grey),
                GestureDetector(
                  child: const ListTile(
                    title: Text("Fotoğraflarım",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                    leading: Icon(
                      Icons.photo,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const FotograflarimPage()));
                  },
                ),
                const Divider(color: Colors.grey),
                GestureDetector(
                  child: const ListTile(
                    title: Text("Hesap Ayarları",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                    leading: Icon(
                      Icons.settings,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const HesapAyarlari()));
                  },
                ),
                const Divider(color: Colors.grey),
                GestureDetector(
                  child: const ListTile(
                    title: Text("Çıkış Yap",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black)),
                    leading: Icon(
                      Icons.output_sharp,
                      color: Colors.black,
                    ),
                  ),
                  onTap: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
                Expanded(child: Container()),
                const Text(
                  "info@gmail.com",
                  style: TextStyle(color: Colors.black),
                ),
                const SizedBox(
                  height: 10,
                )
              ],
            ),
          ),
        ),
        body: pages[currentIndex],
      ),
    );
  }
}
