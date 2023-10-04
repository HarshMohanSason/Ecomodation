import 'package:cloud_firestore/cloud_firestore.dart';

class Message {  //Base Message class

  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp timestamp;
  final String chatRoomID;

  Message({required this.senderID, required this.receiverID, required this.message, required this.timestamp, required this.chatRoomID});


  Map<String, dynamic> toMap() {   //Convert the entire data to map in order to store at the data base

    return {
      'senderId': senderID,
      'receiverID': receiverID,
      'message': message,
      'Timestamp': timestamp,
      'chatRoomID': chatRoomID,
    };

    }
}
