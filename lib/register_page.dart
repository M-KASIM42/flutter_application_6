import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/my_api.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'login_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _userNameController = TextEditingController();
  List<String> userList = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setUserList();
  }
  setUserList()async{
    userList = await getFirebaseUsernames();
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/balik.jpg"), fit: BoxFit.cover)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "BALIK",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const Text(
              "DÜNYASI",
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.normal,
                  color: Colors.white),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: _userNameController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Kullanıcı Adı',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(15)),
                child: TextField(
                  obscureText: true,
                  controller: _passwordController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(15)),
                child: TextFormField(
                  autovalidateMode: AutovalidateMode.always,
                  validator: (value) {
                    if (_passwordController.text.trim() !=
                        _rePasswordController.text.trim()) {
                      return 'Parolalar uyuşmuyor';
                    } else {
                      return null;
                    }
                  },
                  obscureText: true,
                  controller: _rePasswordController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'RePassword',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () async {

                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                String rePassword = _rePasswordController.text.trim();
                String userName = _userNameController.text.trim();
                if (userList.contains(userName)) {
                  showToastMessage("Bu kullanıcı adı alınmıştır. Lütfen başka bir kullanıcı adı seçin.");
                  return;
                }
                if (password == rePassword) {
                  try {
                    await FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        )
                        .then((userCredential) => FirebaseFirestore.instance
                                .collection('users')
                                .doc(userCredential.user!.uid)
                                .set({
                              'email': email,
                              'password': password,
                              'userName': userName,
                              'profilfoto': ""
                            }));
                    MyApi.setUser(userName);
                    MyApi.setEmail(email);
                    MyApi.setProfilFoto("");
                    // E-posta doğrulama e-postası gönderme
                    User? user = FirebaseAuth.instance.currentUser;
                    await user?.sendEmailVerification();

                    showToastMessage("doğrulama e-postası gönderildi");

                    if (context.mounted) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (loginpage) => const LoginPage()),
                      );
                    }
                  } catch (error) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text("Hata"),
                          content: Text(error.toString()),
                        );
                      },
                    );
                  }
                }
              },
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Colors.green,
                ),
                width: 340,
                height: 50,
                child: const Center(
                  child: Text(
                    "Kayıt Ol",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

Future<List<String>> getFirebaseUsernames() async {
  List<String> usernames = [];

  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    
    querySnapshot.docs.forEach((doc) {
      if (doc.exists) {
        var data = doc.data() as Map<String, dynamic>; // Firestore verilerini belirli bir tipe dönüştürme
        if (data.containsKey('userName')) {
          usernames.add(data['userName'] as String); // Dize dönüşümü
        }
      }
    });
  } catch (e) {
    print('Error getting usernames: $e');
    // Hata durumunda boş bir liste döndürebilirsiniz veya hata yönetimini başka bir şekilde yapabilirsiniz.
  }

  return usernames;
}


  void showToastMessage(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.grey[700],
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }
}
