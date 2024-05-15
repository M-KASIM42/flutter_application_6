import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_6/profile_page.dart';

class HesapAyarlari extends StatelessWidget {
  const HesapAyarlari({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hesap Ayarları'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kişisel Bilgiler',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Profil Görüntüle'),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ProfilePage()));
              },
            ),
            const Divider(),
            const Text(
              'Güvenlik',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Şifre Değiştir'),
              onTap: () async {
                try {
                  await FirebaseAuth.instance.sendPasswordResetEmail(
                      email: FirebaseAuth.instance.currentUser!.email!);
                  // ignore: use_build_context_synchronously
                  Navigator.pop(context);
                  // ignore: use_build_context_synchronously
                  showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          content: Text(
                              "Sıfırlama linki mail adresinize gönderilidi"),
                        );
                      });
                } on FirebaseException catch (e) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          content: Text(e.message.toString()),
                        );
                      });
                }
              },
            ),
            const Divider(),
            const Text(
              'Diğer',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: const Text('Dil Seç'),
              onTap: () {
                // Dil seçme ekranına gitmek için navigator kullanabilirsiniz.
              },
            ),
          ],
        ),
      ),
    );
  }
}
