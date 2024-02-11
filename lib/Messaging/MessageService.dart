
import 'dart:async';
import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import 'package:ecomodation/Listings/ListingService.dart';
import 'package:ecomodation/Messaging/MessageEncryption.dart';
import 'package:ecomodation/Messaging/MessageSentSeenStatus.dart';
import '../phoneLogin/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/Message.dart';
import 'package:ecomodation/phoneLogin/OTPpage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:collection/collection.dart';
import 'MessageSenderInfo.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';


class MessageService extends ChangeNotifier {

  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final ListingService _listingService = ListingService();
  var receiverID = ' ';
  final checkMapEquality = const DeepCollectionEquality();
  MessageStatus messageStatus = MessageStatus();

  Future<void> sendMessage(String receiverID, String message, [bool? isSeen]) async {

    //get the current user info

    final String currentUserID = loggedInWithGoogle
        ? googleLoginDocID
        : phoneLoginDocID;
    final Timestamp timestamp = Timestamp.now();

    RSAEncryption rsaEncryption = RSAEncryption();

    var getPublicKey = await rsaEncryption.getReceiverPublicKey(receiverID); //get the public key

    var encryptedMessage = encrypt(message, getPublicKey); //encrypt the message by passing the public key:

    Message newMessage = Message(senderID: currentUserID,
        receiverID: receiverID,
        message: encryptedMessage,
        timestamp: timestamp,
        isSeen: isSeen ?? false);

    var getOwnPublicKey = await rsaEncryption.getOwnPublicKey();

    var ownEncryptedMessage = encrypt(message, getOwnPublicKey);

    Message ownMessage = Message(senderID: currentUserID,
        receiverID: receiverID,
        message: ownEncryptedMessage,
        timestamp: timestamp,
        isSeen: false);

    try {

      if (loggedInWithGoogle == true) {
        await _firebaseFirestore.collection('userInfo').doc(googleLoginDocID)
            .collection('sentMessages').add(ownMessage.toMap());

        await _firebaseFirestore.collection('userInfo').doc(receiverID).
        collection('receivedMessages').add(newMessage.toMap());
      }
      else if (loggedInWithPhone == true) {
        await _firebaseFirestore.collection('userInfo')
            .doc(phoneLoginDocID)
            .collection('sentMessages')
            .add(ownMessage.toMap());

        await _firebaseFirestore.collection('userInfo')
            .doc(receiverID)
            .collection(
            'receivedMessages')
            .add(newMessage.toMap());
      }
    }
    catch (e) {
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
          var documents = await FirebaseFirestore.instance.collection(
              'userInfo')
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
          var documents = await FirebaseFirestore.instance.collection(
              'userInfo')
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
    catch (e) {
      //print(e);
    }
    return newReceiverID;
  }



  Stream<List<QuerySnapshot>> getAllMessagesStream(String senderID) {
    late Stream<
        QuerySnapshot<Map<String, dynamic>>> sentMessagesQuery = const Stream
        .empty();
    late Stream<QuerySnapshot<
        Map<String, dynamic>>> receivedMessagesQuery = const Stream.empty();


    try {
      if (loggedInWithGoogle == true)
        // Query the "sentMessages" collection group across the entire database
          {
        sentMessagesQuery =
            FirebaseFirestore.instance.collection('userInfo').doc(
                googleLoginDocID).collection('sentMessages').
            orderBy('Timestamp', descending: false).where(
                'receiverID', isEqualTo: senderID)
                .snapshots();

        receivedMessagesQuery =
            FirebaseFirestore.instance.collection('userInfo').doc(
                googleLoginDocID).collection('receivedMessages').where(
                'senderID', isEqualTo: senderID)
                .orderBy('Timestamp', descending: false)
                .snapshots();
      }

      else if (loggedInWithPhone == true) {
        sentMessagesQuery =
            FirebaseFirestore.instance.collection('userInfo').doc(
                phoneLoginDocID).collection('sentMessages')
                .orderBy('Timestamp', descending: false).where(
                'receiverID', isEqualTo: senderID)
                .snapshots();
        receivedMessagesQuery =
            FirebaseFirestore.instance.collection('userInfo').doc(
                phoneLoginDocID).collection('receivedMessages').where(
                'senderID', isEqualTo: senderID)
                .orderBy('Timestamp', descending: false)
                .snapshots();
      }
      // Query the "receivedMessages" collection group across the entire database

      // Merge the two streams into one

      var combinedStream = Rx.combineLatest(
          [receivedMessagesQuery, sentMessagesQuery], (
          List<QuerySnapshot> snapshot) => snapshot);

      return combinedStream;
    }

    catch (e) {
      rethrow;
    }
  }


  Stream<QuerySnapshot<Map<String,
      dynamic>>> getEachMessageSenderID() //function to get messages for eachUser
  {
    if (loggedInWithGoogle) { //
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

    else {
      return const Stream.empty();
    }
  }

  Stream<List<QuerySnapshot>> getLastSentMessage(String senderID) {
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
    catch (e) {
      rethrow;
    }
    return const Stream.empty();
  }

  Future<MessageSenderInfo> getSenderInfo(String senderID) async {
    try {
      var document = await FirebaseFirestore.instance.collection('userInfo')
          .doc(senderID)
          .get();
      var senderInfo = document.data();
      return MessageSenderInfo(userName: senderInfo!['username'],
          profileURL: senderInfo['photoURL']);
    }
    catch (e) {
      rethrow;
    }
  }

  Future<void> sendInitialMessageInfo(DetailedListingsStore detailedListingsStore) async
  {
    try {
      var initialMessageSent = await checkInitialMessageSent(
          detailedListingsStore);
      if (initialMessageSent == false) {
        await FirebaseFirestore.instance.collection('userInfo')
            .doc(loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
            .collection('InitialMessageSent').add({
          'ListingID': detailedListingsStore.docID,
          'Timestamp': DateTime.now()
        });
      }
      // The update was successful.
    }
    catch (e) {
      rethrow;
    }
  }

  //Function to check the initial MessageSent
  Future<bool> checkInitialMessageSent(DetailedListingsStore detailedListingsStore) async
  {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
          .collection('InitialMessageSent').where(
          'ListingID', isEqualTo: detailedListingsStore.docID).get();

      return snapshot.docs.isNotEmpty;
    }
    catch (e)
    {
      return Future.value(false);
    }
  }

  //createIsOnlineVal function. Only using this function once each time a first message is sent from both parties

  Future<void> createIsOnlineVal(String senderID) async
  {
    CollectionReference writeUserInfo = FirebaseFirestore.instance.collection('userInfo');  // create a reference to the writeUserInfo collection
    try {
      if(loggedInWithGoogle)
      {
        //write the data in the collection and add isOnline method
        await writeUserInfo.doc(senderID).collection('MessageSeenSocket').add({'isOnline': false, 'senderID': googleLoginDocID});
        await writeUserInfo.doc( googleLoginDocID).collection('MessageSeenSocket').add({'isOnline': false, 'senderID': senderID});
      }
      if(loggedInWithPhone)
        {
          await writeUserInfo.doc(senderID).collection('MessageSeenSocket').add({'isOnline': false, 'senderID': phoneLoginDocID });
          await writeUserInfo.doc(phoneLoginDocID).collection('MessageSeenSocket').add({'isOnline': false, 'senderID': senderID});
        }
    }
    catch(e)
    {
  //   print(e)
    }
  }

  // Function to mark messages seen in the MessageSeenSocket
  Future <void> markOtherUserOnline(String senderID) async  //Function for a messageSeenSocket
  {

    try {

      if (loggedInWithGoogle)
      {
        FirebaseFirestore.instance.collection('userInfo').doc(senderID).collection('MessageSeenSocket').where(
            'senderID', isEqualTo: googleLoginDocID)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            var document = value.docs.first;
            document.reference.update({'isOnline': true});
          }
        });
      }

      if (loggedInWithPhone)
      {
        FirebaseFirestore.instance.collection('userInfo').doc(senderID)
            .collection('MessageSeenSocket').where(
            'senderID', isEqualTo: phoneLoginDocID).get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            var document = value.docs.first;
            document.reference.update({'isOnline': true});
          }
        });
      }
    }
    catch(e)
    {
      //print(e);
    }
  }

  
  //Function to mark the other user offline if he/she leaves the current screen
  Future <void> markOtherUserOffline(String senderID) async
  {
    try {
      if (loggedInWithGoogle) 
      {
        FirebaseFirestore.instance.collection('userInfo').doc(senderID).collection('MessageSeenSocket').where(
            'senderID', isEqualTo: googleLoginDocID)
            .get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            var document = value.docs.first;
            document.reference.update({'isOnline': false});
          }
        });
      }
      if (loggedInWithPhone)
      {
        FirebaseFirestore.instance.collection('userInfo').doc(senderID)
            .collection('MessageSeenSocket').where(
            'senderID', isEqualTo: phoneLoginDocID).get()
            .then((value) {
          if (value.docs.isNotEmpty) {
            var document = value.docs.first;
            document.reference.update({'isOnline': false});
          }
        });
      }
    }
    catch(e)
    {
      //print(e);
    }
  }

  Future<void> markAllMessagesSeen(String otherUserID) async
  {
    try
    {
      await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(otherUserID)
          .collection('sentMessages')
          .where('receiverID', isEqualTo: loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
          .get()
          .then((value) {
        for (var element in value.docs) {
          // Update the document in Firestore with the new value
            if(element.data()['isSeen'] == false)
            {
              element.reference.update({'isSeen': true});
            }
        }
      });
    }
    catch(e)
    {
      //print(e)
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getIsOnlineStream(String otherUserID) {
    try {
      return FirebaseFirestore.instance
          .collection('userInfo')
          .doc(loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID)
          .collection('MessageSeenSocket')
          .where('senderID', isEqualTo: otherUserID)
          .snapshots()
          .handleError((error) {
        // Handle errors that occur during streaming setup
        print("Error during streaming setup: $error");
      });
    }
    catch (e) {
      // Handle any unexpected errors during setup
      print("Unexpected error during streaming setup: $e");
      return FirebaseFirestore.instance
          .collection('userInfo')
          .doc()
          .collection('MessageSeenSocket')
          .where('senderID', isEqualTo: otherUserID)
          .snapshots()
          .handleError((error) {
        // Handle errors that occur during streaming setup
        print("Error during streaming setup: $error");
      });
    }
  }

   //function to format time for each Message
    String formatMessageTime(Timestamp messsageTimeStamp)
    {
    DateTime messageTime = DateTime.fromMillisecondsSinceEpoch(messsageTimeStamp.millisecondsSinceEpoch).toLocal(); //convert the time to the local time

      if (messageTime.hour > 12 ) {

        if(messageTime.minute < 10)
          {
            return "${messageTime.hour - 12}:0${messageTime.minute} PM";
          }
        return "${messageTime.hour - 12}:${messageTime.minute} PM";

      }
      else if(messageTime.hour == 0)
      {

        if(messageTime.minute < 10)
          {
            return "${messageTime.hour + 12}:0${messageTime.minute} AM";
          }

        return "${messageTime.hour + 12}:${messageTime.minute} AM";
      }
      else
        {

          if(messageTime.minute < 10)
            {
              return "${messageTime.hour}:0${messageTime.minute} AM";
            }

          return "${messageTime.hour}:${messageTime.minute} AM";
        }
    }

  }

