import 'package:ecomodation/homepage.dart';
import'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../loginpage.dart';

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({Key? key}) : super(key: key);

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}

class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot)
          {
            if(snapshot.hasData)
              {
                return  MainScreen();
              }

          else
            {
              return const LoginScreen();
            }

          }
      ),
    );
  }
}
