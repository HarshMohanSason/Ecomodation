import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/Listings/ListingService.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/Message.dart';
import 'package:ecomodation/OTPpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';


class MessageService extends ChangeNotifier {

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final ListingService _listingService = ListingService();
  var receiverID = '';

  Future<void> sendMessage(String receiverID, String message) async {


    //get the current user info

    final String currentUserID = _firebaseAuth.currentUser!.uid;
    final Timestamp timestamp = Timestamp.now();
    final chatRoomID = currentUserID + receiverID;
        Message newMessage = Message(senderID: currentUserID,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        chatRoomID: chatRoomID);
    //create a new message


    List<String> ids = [currentUserID, receiverID];
    ids.sort();

    if (loggedInWithGoogle == true) {
      await _firebaseFirestore.collection('userInfo')
          .doc(googleLoginDocID)
          .collection('sentMessages')
          .add(newMessage.toMap());

      await _firebaseFirestore.collection('userInfo').doc(receiverID).collection('receivedMessages').add(newMessage.toMap());

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


  Future<String> getrecieverID(Map<String, dynamic> currentListingInfo) async
  {
    List<String> listingIDs = await _listingService.getDistances();

    if (loggedInWithGoogle == true) {
      for (int i = 0; i < listingIDs.length; i++) {
        var documents = await FirebaseFirestore.instance.collection('userInfo')
            .doc(listingIDs[i]).collection('ListingInfo').get();

        for (var snapshot in documents.docs) {
          Map<String, dynamic> listingInfo = snapshot.data();
          if (listingInfo.values == currentListingInfo.values &&
              listingInfo.length == currentListingInfo.length &&
              listingInfo.keys == currentListingInfo.keys) {
            break;
          }
        }
        receiverID = listingIDs[i];
        return listingIDs[i];
      }
    }

    else if (loggedInWithPhone == true) {
      for (int i = 0; i < listingIDs.length; i++) {
        var documents = await FirebaseFirestore.instance.collection('userInfo')
            .doc(listingIDs[i]).collection('ListingInfo').get();

        for (var snapshot in documents.docs) {
          Map<String, dynamic> listingInfo = snapshot.data();
          if (listingInfo.values == currentListingInfo.values &&
              listingInfo.length == currentListingInfo.length &&
              listingInfo.keys == currentListingInfo.keys) {
            break;
          }
        }
        receiverID = listingIDs[i];
        return listingIDs[i];
      }
    }
    return '';
  }

  Stream<QuerySnapshot> getAllMessagesStream() {
    try {
      // Query the "sentMessages" collection group across the entire database
      var sentMessagesQuery = FirebaseFirestore.instance.collectionGroup('sentMessages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      // Query the "receivedMessages" collection group across the entire database
      var receivedMessagesQuery = FirebaseFirestore.instance
          .collectionGroup('receivedMessages')
          .orderBy('timestamp', descending: true)
          .snapshots();

      // Merge the two streams into one
      var mergedStream = Rx.merge([sentMessagesQuery, receivedMessagesQuery]);

      return mergedStream;
    }
    catch (e) {
     // print('Error creating message stream: $e');
      rethrow; // Handle the error as needed
    }
  }

}
