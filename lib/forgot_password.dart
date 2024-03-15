// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      backgroundColor: Colors.amber,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            "Mail adresinize parola sıfırlama linki göndereceğiz.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20,color: Colors.white),
          ),
          SizedBox(height: 10,),
          Text("Lütfen mail adresinizi giriniz",textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20,color: Colors.white),),
          Container(
            height: 80,
            width: 400,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white,
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: TextField(
                  keyboardType: TextInputType.emailAddress,
                  
                  controller:_emailController ,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    
                  ),
                ),
              ),
            ),
          SizedBox(height: 20,),
          GestureDetector(
            onTap: ()async{
              try {
                await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                Navigator.pop(context);
                showDialog(context: context, builder: (context){
                  return AlertDialog(content: Text("Sıfırlama linki mail adresinize gönderilidi"),);
                });
                
                
              }on FirebaseException catch (e) {
                showDialog(context: context, builder: (context){
                  return AlertDialog(content: Text(e.message.toString()),);
                });
              }
              
            },
            child: Container(
              height: 50,
              width: 150,
              decoration: BoxDecoration(
                color: Colors.greenAccent,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Center(child: Text("Send Reset link")),
            ),
          )
        ],
      ),
    );
  }
}
