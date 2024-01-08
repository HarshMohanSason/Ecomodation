

import '../phoneLogin/LoginWithPhone.dart';
import 'package:ecomodation/phoneLogin/OTPpage.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/cupertino.dart';

import 'auth_provider.dart';

class GetUserIDAndFlag extends ChangeNotifier {

  Future<String?> getCurrentDocID() async
  {
    try {
      if ((await storage.containsKey(key: 'googleLoginDocID'))) { //if it contains googleLoginD
        googleLoginDocID = (await storage.read(key: 'googleLoginDocID'))!;
        loggedInWithGoogle = true;
        return googleLoginDocID;
      }
      else if ((await storage.containsKey(key: 'phoneLoginDocID'))) {
        phoneLoginDocID = (await storage.read(key: 'phoneLoginDocID'))!;
        loggedInWithPhone = true;
        return phoneLoginDocID;
      }
    }
    catch (e) {
     const Center(child:  Text("Error retrieving Login Session"));
    }
 return null; }
}