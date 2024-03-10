

import 'package:ecomodation/homeScreenUI.dart';
import 'package:flutter/material.dart';
import 'IntroLoginPageUI.dart';
import '../main.dart';

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({Key? key}) : super(key: key);

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}


class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {


  @override
  void initState() {

    super.initState();
    checkIfLoggedIn();
  }

  @override
  void dispose()
  {
    super.dispose();
  }

  Future<void> initFuture() async {
    await checkIfLoggedIn();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: checkIfLoggedIn(),
          builder: (context, snapshot) {

            if(snapshot.connectionState == ConnectionState.waiting)
              {
                return const CircularProgressIndicator();
              }
            else if(snapshot.data == true)
              {
                return HomeScreenUI();
              }
            else
              {
                return const LoginScreen();
              }
          }
      ),
    );
  }


  Future<bool> checkIfLoggedIn() async
  {
    try {
      if ((await storage.containsKey(key: 'LoggedIn'))) {
        return true;
      }
    }
    catch (e) {
      rethrow;
    }
    return false;
  }

}
