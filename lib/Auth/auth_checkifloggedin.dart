import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/homeScreenUI.dart';
import'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../loginpage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';


final storage =  FlutterSecureStorage(); //create a storage

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({Key? key}) : super(key: key);

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}


class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {

  @override
  void initState()
  {
    super.initState();
    checkLoggedInStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot)
          {
            if(snapshot.hasData)
              {

                return  HomeScreenUI();
              }

          else
            {
              return const LoginScreen();
            }

          }
      ),
    );
  }


  Future<void> checkLoggedInStatus() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {

      googleLoginDocID = (await storage.read(key: 'googleLoginDocID'))!;

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreenUI(),
          ),
        );
      }
    }
  }
}
