
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/PhoneLogin/LoginWithPhone.dart';
import 'package:flutter/cupertino.dart';

class AppSettingsService {

  Future<Map<String, Map<String, dynamic>>> yourListings() async
  {
    Map<String, Map<String, dynamic>> listings = {};
    try {
      var snapshot = await FirebaseFirestore.instance.collection('userInfo')
          .doc(
          loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID).collection(
          'ListingInfo')
          .get();

      for (var element in snapshot.docs) {
        listings[element.id] = element.data();
      }
    }
    catch (e) {
      const Center(child: Text("Error Getting your listings "));
    }
    return listings;
  }


  Future<Map<String, dynamic>> listingsContacted() async {

    Map<String, dynamic> listingData = {};

    try {
      var snapshot = await FirebaseFirestore.instance.collection('userInfo')
          .doc(loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
          .collection('InitialMessageSent')
          .get();

      for (var element in snapshot.docs) {
        listingData['ListingId'] = element.data()['ListingID'];
        listingData['TimeStamp'] = element.data()['TimeStamp'];
      }
    }

    catch (e) {
      const Center(child: Text('Could not fetch the Listings Contacted'));
    }

    return listingData;
  }

  String aboutUs()
  {
    return "";

  }

  String privacyPolicy()
  {
    return "";
  }

  Future<dynamic> savedListings() async
  {

  }

}