
import 'package:chat_bubbles/chat_bubbles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../main.dart';


class ChatBubble extends StatelessWidget {
  // This class will help us create chat bubbles fo sending messages

  final String text; //Text for the message
  final bool isCurrentUser; //To check if the message sent is by the current user so we can adjust the color of the sent messages
  final bool? isSeen;
  const ChatBubble({Key? key, required this.text, required this.isCurrentUser, this.isSeen})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5.0),
      child: BubbleNormal(
   //   sent: isCurrentUser && !isSeen!,
     // seen: isCurrentUser && isSeen!,
      constraints: BoxConstraints(
      maxWidth: screenWidth - 70
      ),
      text: text,
      textStyle: TextStyle(

      color: isCurrentUser ? Colors.white : Colors.black,
      fontSize: 16
      ),
      color: isCurrentUser ? Colors.black87  :  Colors.black26,
      isSender: isCurrentUser ? true : false,
      ),
      );

  }
}