import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:ecomodation/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class MessageDisplay extends StatefulWidget {

  final String receiverID;

  const MessageDisplay({Key? key, required this.receiverID}) : super(key: key);

  @override
  State<MessageDisplay> createState() => _MessageDisplayState();
}

class _MessageDisplayState extends State<MessageDisplay> {

  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageSerivce = MessageService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;


  @override
  void initState() {
    super.initState();

    // Initialize the stream to receive all messages
  }

  void sendMessage() async
  {
    if(_messageController.text.isNotEmpty)
    {
      await _messageSerivce.sendMessage(widget.receiverID, _messageController.text);
    }
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text('') ,
      backgroundColor: colorTheme,),
      body: Column(

        children: [

          Expanded(child: _buildMessageList()),

          _buildMessageInput(),
      ],
    ),
    );
  }

  Widget _buildMessageList() {

    Stream<QuerySnapshot> allMessagesStream =  _messageSerivce.getAllMessagesStream();

    return StreamBuilder(
      stream: allMessagesStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text('Error ${snapshot.error}');
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading');
        }

        // Check if snapshot.data is not null before accessing its properties
        if (snapshot.data != null) {
          return ListView(
            children: snapshot.data!.docs.map((document) => _buildMessageItem(document)).toList(),
          );
        } else {
          // Handle the case where snapshot.data is null (no data available)
          return const Text('No new Messages');
        }
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot document)
  {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;

    var alignment = (data['senderID'] == _firebaseAuth.currentUser!.uid) ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        children: [
         // Text(data['senderID']),
          Text(data['message']),
        ],
      ),
    );
  }


  Widget _buildMessageInput()
  {
    return Row(
      children: [
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 30),
              child: TextField(
               controller: _messageController,
               obscureText: false,
               decoration: InputDecoration(
                 hintText: 'Send Message',
                 border: OutlineInputBorder(
                 borderRadius: BorderRadius.circular(25),
                 borderSide: const BorderSide(   //decorate the border of the box
                 width: 8,
                 style: BorderStyle.solid,  //style of the border
                 color: Color(0x000000FF),  //color of the borderlines
                  ),
                ) ,
              ),
            ),
          ),
        ),

        Padding(padding: const EdgeInsets.only(bottom: 50, right: 10), child:
            IconButton(onPressed: () => sendMessage(), icon: const Icon(Icons.send, size: 45, color: colorTheme,))),
      ],
    );
  }

}
