
import 'dart:async';
import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/Listings/ListingService.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/Message.dart';
import 'package:ecomodation/OTPpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';


class MessageService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final ListingService _listingService = ListingService();
  var receiverID = ' ';
  final checkMapEquality = const DeepCollectionEquality();

  Future<void> sendMessage(String receiverID, String message) async {

    //get the current user info

    final String currentUserID = loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID;
    final Timestamp timestamp = Timestamp.now();
    final senderName = loggedInWithGoogle ? googleUserName : phoneUserName;
        Message newMessage = Message(senderID: currentUserID,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        senderName: senderName);
    //create a new message


    if (loggedInWithGoogle == true) {
      await _firebaseFirestore.collection('userInfo').doc(googleLoginDocID)
          .collection('sentMessages').add(newMessage.toMap());

      await _firebaseFirestore.collection('userInfo').doc(receiverID).
          collection('receivedMessages').add(newMessage.toMap());

    }
    else if (loggedInWithPhone == true) {
      await _firebaseFirestore.collection('userInfo')
          .doc(phoneLoginDocID)
          .collection('sentMessages')
          .add(newMessage.toMap());

      await _firebaseFirestore.collection('userInfo').doc(receiverID).collection('receivedMessages').add(newMessage.toMap());

    }
    /*  else if(loggedinWithApple == true)
      {

      }

   */


    //construct a chatroom id from current user id and receiver id (Improve uniqueness)

    //add new message to the database
  }



  Future<String> getReceiverID(Map<String, dynamic> currentListingInfo) async
  {
    var newReceiverID = ' ';

    List<String> listingIDs = await _listingService.getDistances();

    if (loggedInWithGoogle == true) {
      for (int i = 0; i < listingIDs.length; i++) {
        var documents = await FirebaseFirestore.instance.collection('userInfo')
            .doc(listingIDs[i]).collection('ListingInfo').get();

        for (var snapshot in documents.docs)
        {
          Map<String, dynamic> listingInfo = snapshot.data();

          if (checkMapEquality.equals(listingInfo, currentListingInfo) == true)
          {
            newReceiverID = listingIDs[i];
            receiverID = newReceiverID;
            return newReceiverID;
          }
          break;
        }


      }
    }

    else if (loggedInWithPhone == true) {
      for (int i = 0; i < listingIDs.length; i++) {
        var documents = await FirebaseFirestore.instance.collection('userInfo')
            .doc(listingIDs[i]).collection('ListingInfo').get();

        for (var snapshot in documents.docs) {
          Map<String, dynamic> listingInfo = snapshot.data();
          if (checkMapEquality.equals(listingInfo, currentListingInfo) == true) {
            break;
          }
        }
        newReceiverID = listingIDs[i];
        receiverID = newReceiverID;
        return newReceiverID;
      }
    }
    return ' ';
  }

  Stream<List<QuerySnapshot>> getAllMessagesStream(String senderID) {

   late Stream<QuerySnapshot<Map<String, dynamic>>> sentMessagesQuery = const Stream.empty();
   late Stream<QuerySnapshot<Map<String, dynamic>>> receivedMessagesQuery  = const Stream.empty();


    try {
      if (loggedInWithGoogle == true)
        // Query the "sentMessages" collection group across the entire database
          {
        sentMessagesQuery =
            FirebaseFirestore.instance.collection('userInfo').doc(
                googleLoginDocID).collection('sentMessages').
                orderBy('Timestamp', descending: false).where('receiverID', isEqualTo: senderID)
                .snapshots();

        receivedMessagesQuery = FirebaseFirestore.instance.collection('userInfo').doc(
            googleLoginDocID).collection('receivedMessages').where('senderID', isEqualTo: senderID)
            .orderBy('Timestamp', descending: false)
            .snapshots();
      }

      else if (loggedInWithPhone == true)
    {
      sentMessagesQuery =
          FirebaseFirestore.instance.collection('userInfo').doc(
              phoneLoginDocID).collection('sentMessages')
              .orderBy('Timestamp', descending: false).where('receiverID', isEqualTo: senderID)
              .snapshots();
      receivedMessagesQuery = FirebaseFirestore.instance.collection('userInfo').doc(
          phoneLoginDocID).collection('receivedMessages').where('senderID', isEqualTo: senderID)
          .orderBy('Timestamp', descending: false)
          .snapshots();
    }
      // Query the "receivedMessages" collection group across the entire database

      // Merge the two streams into one

      var combinedStream = Rx.combineLatest([receivedMessagesQuery, sentMessagesQuery], (List<QuerySnapshot> snapshot) => snapshot);

      return combinedStream;
    }

    catch (e) {

     rethrow;
    }
  }


  Stream<QuerySnapshot<Map<String, dynamic>>> getEachMessageSenderID()  //function to get messages for eachUser
  {
    if (loggedInWithGoogle) {        //
      return FirebaseFirestore.instance
          .collection('userInfo')
          .doc(googleLoginDocID)
          .collection('receivedMessages').orderBy('senderID')
          .snapshots();

    }
    else if (loggedInWithPhone) {
      return FirebaseFirestore.instance
          .collection('userInfo')
          .doc(phoneLoginDocID)
          .collection('receivedMessages').orderBy('senderID')
          .snapshots();
    }

  else
    {
      return const Stream.empty();
    }
  }
}
