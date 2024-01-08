import 'package:cloud_firestore/cloud_firestore.dart';

class Message {  //Base Message class

  final String senderID; //Sender's ID
  final String receiverID; //Receiver's ID
  final String message; //String containing the message
  final List<String> imageURLS; //Set of images sent to the other user
  final Timestamp timestamp; //Timestamp for the messages
  bool isSeen; //to check whether the message has been seen or not

  Message({required this.senderID, required this.receiverID,  this.message = '', required this.timestamp, this.imageURLS = const [], this.isSeen = false });

  Map<String, dynamic> toMap() {   //Convert the entire data to map in order to store at the data base
    return {
      'senderID': senderID,
      'receiverID': receiverID,
      'message': message,
      'Timestamp': timestamp,
      'isSeen': isSeen,
    };
  }
}

