
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:flutter/cupertino.dart';

import '../UserLogin/GoogleLogin/GoogleAuthService.dart';
import '../UserLogin/PhoneLogin/LoginWithPhoneUI.dart';

class AppSettingsService {

  Future<Map<String, Map<String, dynamic>>> yourListings() async
  {
    Map<String, Map<String, dynamic>> listings = {};
    try {
      var snapshot = await FirebaseFirestore.instance.collection('userInfo')
          .doc(
          FirebaseAuth.instance.currentUser!.uid).collection(
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
          .doc(FirebaseAuth.instance.currentUser!.uid)
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

  Future<bool> updateMarkRented(bool markRented) async
  {
    try {
      await FirebaseFirestore.instance.collection('userInfo').doc(
          FirebaseAuth.instance.currentUser!.uid).collection(
          'ListingInfo').doc().update(
          {'Rented': markRented});

      return true;
    }

    catch (e) {
      const Center(child: Text("Could not mark rented, please try again"));
    }

    return false;
  }

  String aboutUs() {
    return "";
  }

  String privacyPolicy() {
    return "";
  }

  Future<void> saveListing(DetailedListingsStore detailedListingsStore) async {
    try {
      // Check if a listing with the same 'imageInfoList' already exists
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('savedListings')
          .where('imageInfoList',
          isEqualTo: detailedListingsStore.listingInfo['imageInfoList'])
          .get();

      if (querySnapshot.docs.isEmpty) {
        // No matching listing found, proceed to add the new listing
        await FirebaseFirestore.instance
            .collection('userInfo')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('savedListings')
            .add(detailedListingsStore.toMap());
      }
    }
    catch (e) {
      Center(child: Text("Error saving the list: $e"));
      // Handle error, display error message, etc.
    }
  }

  Future<List<Map<String, dynamic>>> getSavedListing() async {
    List<Map<String, dynamic>> savedListings = [];
    try {
      var snapshot = await FirebaseFirestore.instance.collection('userInfo')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .collection('savedListings')
          .get();
      for (var element in snapshot.docs) {
        savedListings.add(element.data());
      }
    }
    catch (e) {
      const Center(child: Text("Could not fetch the listings"));
    }
    return savedListings;
  }

  Future<void> deleteSavedListings(List<Map<String, dynamic>> list) async
  {
    try {
      var snapshot = await FirebaseFirestore.instance.collection('userInfo')
          .doc(
          FirebaseAuth.instance.currentUser!.uid).collection(
          'savedListings')
          .get();

      for (var docSnapshot in snapshot.docs) {
        var data = docSnapshot.data();

        // Check if the data matches any item in the list
        if (list.any((map) => map['imageInfoList'].first.toString() == data['imageInfoList'].first.toString())) {
          await docSnapshot.reference.delete(); // Delete the document
        }
      }
    }

    catch (e) {
      Center(child: Text("Could not delete the listings: + $e"));
    }
  }



}