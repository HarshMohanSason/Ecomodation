
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'chatBubble.dart';


class MessageDisplay extends StatefulWidget {

  final String receiverID;


  const MessageDisplay({Key? key, required this.receiverID}) : super(key: key);

  @override
  State<MessageDisplay> createState() => _MessageDisplayState();
}


class _MessageDisplayState extends State<MessageDisplay> {

  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageService = MessageService();
  final GlobalKey<FormState> sendMessageKey = GlobalKey<FormState>();
  List<dynamic> thisUserMessages = []; //local list to hold messages for the current user

  final ScrollController _scrollController = ScrollController(); //manage scrolling of messages

  bool checkIfEmpty = false;

  @override

  void initState() {
    super.initState();
    // Initialize the stream to receive all messages
  }

  void sendMessage() async
  {
    if(_messageController.text.isNotEmpty)  //check if the message is not null,
    {
      await _messageService.sendMessage(widget.receiverID, _messageController.text);  //sent the message to database
      _messageController.clear(); //clear the message box
      _scrollController.animateTo(_scrollController.position.minScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut); //scroll to the new Message once the messages is sent
    }

  }


  @override
  Widget build(BuildContext context) {

   // final showAskButtonState = Provider.of<DetailedListingStateManage>(context, listen: false); //create instance of the addListingState here.

    return Scaffold(
      //appBar: AppBar(title: const Text('') ,
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top:60),
            child: Align(
              alignment: const Alignment(-1,-0.6),
              child: IconButton (
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
              ),
            ),
          ),
          Expanded(child: _buildMessageList()),

          Padding(
              padding: const EdgeInsets.only(right: 13),
              child: Center(child: _buildMessageInput())),
      ],
    ),
    );
  }

  Widget _buildMessageList() {

    Stream<List<QuerySnapshot>> allMessagesStream =  _messageService.getAllMessagesStream(widget.receiverID);

    return StreamBuilder<List<QuerySnapshot>>(
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

        List<QuerySnapshot> snapshots = snapshot.data!;
          thisUserMessages.clear();

        for (var document in snapshots) {
          var messages = document.docs.map((element) => element.data() as Map<String, dynamic>).toList();
          thisUserMessages.addAll(messages); // add messages to the list
        }

        thisUserMessages.sort((a, b) => (b['Timestamp'] as Timestamp).compareTo(a['Timestamp'] as Timestamp)); //sort all the messages by their timestamp


         return ListView.builder(
          reverse: true, //reverse display the items
           controller: _scrollController,
            itemCount: thisUserMessages.length,
            itemExtent: 70.0, //space between the items in the list
            itemBuilder: (context, index) {
              //build the messages
              return _buildMessageItem(thisUserMessages[index]);
            },
          );

        } else {
          // Handle the case where snapshot.data is null (no data available)
          return const Text('No new Messages');
        }
      },
    );
  }


  Widget _buildMessageItem(Map<String, dynamic> messageData) {


  var alignment = messageData['senderID'] == widget.receiverID; //check if the message sent by the user matches with that receiverID.

    return ChatBubble(
      text: messageData['message'],
      isCurrentUser: alignment ? false : true
    );

}


  Widget _buildMessageInput()
  {


    return Row(
      children: [
        Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 30),
              child: Form(
                key: sendMessageKey,
                child: TextField(
                   controller: _messageController,
                   obscureText: false,
                   decoration: InputDecoration(
                   hintText: 'Enter your message here',
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
        ),

        Padding(padding: const EdgeInsets.only(bottom: 45, right: 10), child:
            IconButton(onPressed: () {

            sendMessage();

            }, icon: const Icon(Icons.send, size: 45, color: colorTheme,))),

      ],
    );
  }

}
