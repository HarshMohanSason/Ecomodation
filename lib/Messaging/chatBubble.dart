
import 'package:ecomodation/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget { // This class will help us create chat bubbles fo sending messages

  final String text;  //Text for the message
  final bool isCurrentUser; //To check if the message sent is by the current user so we can adjust the color of the sent messages
  const ChatBubble({Key? key, required this.text, required this.isCurrentUser}) : super(key: key);

  @override

  Widget build(BuildContext context) {
    return Padding(
      padding:  const EdgeInsets.only(left: 7),
      child: Align(
        alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: screenWidth/1.55,
          ),
          child: DecoratedBox(
            decoration: BoxDecoration(
            color: isCurrentUser ? Colors.green : Colors.grey, // if it is the current user, then we display the color of the bubble as green
            borderRadius: BorderRadius.circular(16), //set the border radius for the chat bubbles
          ),
          child: Padding(
              padding: const EdgeInsets.all(15),
            child: Text(
              text, style: const TextStyle(color: Colors.black),
             ),
          ),),
        ),
      ),
    );
  }
}
