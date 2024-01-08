
import 'dart:async';
import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import 'package:ecomodation/Listings/ListingService.dart';
import 'package:ecomodation/Messaging/MessageSentSeenStatus.dart';
import '../phoneLogin/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/Message.dart';
import 'package:ecomodation/phoneLogin/OTPpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'MessageSenderInfo.dart';


class MessageService extends ChangeNotifier {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final ListingService _listingService = ListingService();
  var receiverID = ' ';
  final checkMapEquality = const DeepCollectionEquality();
  MessageStatus messageStatus = MessageStatus();

  Future<void> sendMessage(String receiverID, String message) async {

    //get the current user info
    final String currentUserID = loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID;
    final Timestamp timestamp = Timestamp.now();
        Message newMessage = Message(senderID: currentUserID,
        receiverID: receiverID,
        message: message,
        timestamp: timestamp,
        isSeen: false);

    //create a new message
            try{
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

                await _firebaseFirestore.collection('userInfo').doc(receiverID).collection(
                    'receivedMessages').add(newMessage.toMap());
              }
            }
            catch(e)
                {
                  //print(messageStatus.isMessageSent);
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
    var newReceiverID = '';

    List<String> listingIDs = await _listingService.getListingsInUserDistance();

   try {
     if (loggedInWithGoogle == true) {
       for (int i = 0; i < listingIDs.length; i++) {
         var documents = await FirebaseFirestore.instance.collection('userInfo')
             .doc(listingIDs[i]).collection('ListingInfo').get();

         for (var snapshot in documents.docs) {
           Map<String, dynamic> listingInfo = snapshot.data();

           if (checkMapEquality.equals(listingInfo, currentListingInfo) ==
               true) {
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
           if (checkMapEquality.equals(listingInfo, currentListingInfo) ==
               true) {
             break;
           }
         }
         newReceiverID = listingIDs[i];
         receiverID = newReceiverID;
         return newReceiverID;
       }
     }
   }
   catch(e)
    {
      //print(e);
    }
    return newReceiverID;
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

  Stream<List<QuerySnapshot>> getLastSentMessage(String senderID)
  {
    try {
      if (loggedInWithGoogle == true) {
        var receivedMessageQuery = FirebaseFirestore.instance.collection(
            'userInfo').doc(
            googleLoginDocID).collection('receivedMessages').where(
            'senderID', isEqualTo: senderID)
            .orderBy('Timestamp', descending: true).limit(1)
            .snapshots();

        var sentMessagesQuery = FirebaseFirestore.instance.collection(
            'userInfo').doc(
            googleLoginDocID).collection('sentMessages').where(
            'receiverID', isEqualTo: senderID)
            .orderBy('Timestamp', descending: true).limit(1)
            .snapshots();

        var combinedStream = Rx.combineLatest(
            [receivedMessageQuery, sentMessagesQuery], (
            List<QuerySnapshot> snapshot) => snapshot);

        return combinedStream;
      }

      else if (loggedInWithPhone == true) {
        var receivedMessageQuery = FirebaseFirestore.instance.collection(
            'userInfo').doc(
            googleLoginDocID).collection('receivedMessages').where(
            'senderID', isEqualTo: senderID)
            .orderBy('Timestamp', descending: true).limit(1)
            .snapshots();

        var sentMessagesQuery = FirebaseFirestore.instance.collection(
            'userInfo').doc(
            googleLoginDocID).collection('sentMessages').where(
            'receiverID', isEqualTo: senderID)
            .orderBy('Timestamp', descending: true).limit(1)
            .snapshots();

        var combinedStream = Rx.combineLatest(
            [receivedMessageQuery, sentMessagesQuery], (
            List<QuerySnapshot> snapshot) => snapshot);

        return combinedStream;
      }
    }
    catch(e)
    {
      rethrow;
    }
    return const Stream.empty();
  }

  Future<MessageSenderInfo> getSenderInfo(String senderID) async{

    try{
      var document = await FirebaseFirestore.instance.collection('userInfo').doc(senderID).get();
      var senderInfo = document.data();
      return MessageSenderInfo(userName: senderInfo!['username'], profileURL: senderInfo['photoURL'] );
    }
    catch(e)
    {
      rethrow;
    }
  }


  Future<void> sendInitialMessageInfo(DetailedListingsStore detailedListingsStore) async
  {
    try {

      var initialMessageSent = await checkInitialMessageSent(detailedListingsStore);
      if(initialMessageSent == false) {
        await FirebaseFirestore.instance
            .collection('userInfo')
            .doc(loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
            .collection('InitialMessageSent').add({
          'ListingID': detailedListingsStore.docID,
          'Timestamp': DateTime.now()
        });
      }
      // The update was successful.
    } catch (e) {

      rethrow;
    }
  }

  Future<bool> checkInitialMessageSent(DetailedListingsStore detailedListingsStore)
  async {

    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
          .collection('InitialMessageSent').where(
          'ListingID', isEqualTo: detailedListingsStore.docID).get();

      return snapshot.docs.isNotEmpty;
    }

    catch(e)
    {
      return Future.value(false);
    }

  }

  Future <bool> markMessageSeen(String senderID) //Function to mark a message which has been seen.
  async{

    var snapshot = await FirebaseFirestore.instance.collection('userInfo').doc(senderID).collection('sentMessages').orderBy('Timestamp', descending: true).limit(1).get();

  if(snapshot.docs.isNotEmpty)
    {
      String latestSentMessageID = snapshot.docs.first.id;

      await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(senderID)
          .collection('sentMessages')
          .doc(latestSentMessageID)
          .update({'isSeen': true});
      return true;
    }
return false;}
}
