import 'package:cloud_firestore/cloud_firestore.dart';

class Message {  //Base Message class

  final String senderID;
  final String receiverID;
  final String message;
  final Timestamp timestamp;

  Message({required this.senderID, required this.receiverID, required this.message, required this.timestamp});

  Map<String, dynamic> toMap() {   //Convert the entire data to map in order to store at the data base
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'Timestamp': timestamp,
    };
  }
}
