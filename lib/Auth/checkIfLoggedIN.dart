

import 'package:ecomodation/homeScreenUI.dart';
import 'package:flutter/material.dart';
import '../IntorLoginPage.dart';
import 'getUserIDandFlag.dart';

class CheckIfLoggedIn extends StatefulWidget {
  const CheckIfLoggedIn({Key? key}) : super(key: key);

  @override
  State<CheckIfLoggedIn> createState() => _CheckIfLoggedInState();
}


class _CheckIfLoggedInState extends State<CheckIfLoggedIn> {
  late final GetUserIDAndFlag _getUserIDAndFlag;

  @override
  void initState() {
    super.initState();
   _getUserIDAndFlag = GetUserIDAndFlag();
  }

  @override
  void dispose()
  {
    super.dispose();
   _getUserIDAndFlag.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
          future: _getUserIDAndFlag.getCurrentDocID(),
          builder: (context, snapshot) {

            if(snapshot.connectionState == ConnectionState.waiting)
              {
                return const CircularProgressIndicator();
              }
            else if(snapshot.hasError)
              {
                return const Center(child: Text("Error logging in, Please try again"));
              }
            else if(snapshot.hasData)
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

}
