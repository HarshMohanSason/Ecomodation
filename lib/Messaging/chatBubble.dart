
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';


class ChatBubble extends StatelessWidget {
  // This class will help us create chat bubbles fo sending messages

  final String text; //Text for the message
  final bool isCurrentUser; //To check if the message sent is by the current user so we can adjust the color of the sent messages
  final bool isSeen;
  final String timeStamp;

  const ChatBubble({Key? key, required this.text, required this.isCurrentUser, required this.isSeen, required this.timeStamp})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: Column(
        children: [

          BubbleNormal(
           //  sent: isCurrentUser && !isSeen!,
          seen: isCurrentUser && isSeen? true : false,
          sent: isCurrentUser && !isSeen ? true : false,
          constraints: BoxConstraints(
          maxWidth: screenWidth - 70
          ),
          text: text,
          textStyle: TextStyle(
          color: isCurrentUser ? Colors.white : Colors.black,
          fontSize: 16
          ),
          color: isCurrentUser ? Colors.black87  :  const Color(0xd3d3d3d3),
          isSender: isCurrentUser ? true : false,
          ),

          Align(
              alignment: isCurrentUser? Alignment.centerRight: Alignment.centerLeft,
              child: Padding(
                padding: isCurrentUser? const EdgeInsets.only(right: 20) : const EdgeInsets.only(left: 20),
                child: Text(timeStamp, style: const TextStyle(fontSize: 9)),
              )),
        ],
      )
    );

  }
}