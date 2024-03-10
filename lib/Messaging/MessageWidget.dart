
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'chatBubble.dart';
import 'MessageEncryption.dart';


class MessageDisplay extends StatefulWidget {

  final String receiverID;
  final String? profileURL;
  final String userName;
  const MessageDisplay({Key? key, required this.receiverID, required this.profileURL, required this.userName}) : super(key: key);

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
  bool isOtherUserOnline = false;
  late RSAPrivateKey rsaPrivateKey;
  late Stream<List<QuerySnapshot>> allMessagesStream; //stream to get all the messages

  @override

  void initState() {

    super.initState();
    initPrivateKey();
    _messageService.markAllMessagesSeen(widget.receiverID);
    _messageService.markOtherUserOnline(widget.receiverID);
    allMessagesStream =  _messageService.getAllMessagesStream(widget.receiverID);    // Initialize the stream to receive all messages
    var getStream =  _messageService.getIsOnlineStream(widget.receiverID);
    getStream.listen((event) {
      if(mounted){
      setState(() {
            if(event.docs.isNotEmpty) {
              isOtherUserOnline =  event.docs.first.data()['isOnline'];
            }
            else
              {
                isOtherUserOnline = false;
              }
      });}
    });
    }

  @override
  void dispose()
  {
    super.dispose();
    _messageController.dispose();
    _messageService.dispose();
    _scrollController.dispose();

  }

  Future<void> initPrivateKey() async
  {
     RSAEncryption rsaEncryption = RSAEncryption();
     rsaPrivateKey = await rsaEncryption.getPrivateKey();
  }

  void sendMessage() async
  {
    _messageService.sendMessage(widget.receiverID, _messageController.text, isOtherUserOnline); //sent the message to database

      _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut); //scroll to the new Message once the messages is sent
  }


  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colorTheme,
          leadingWidth: 40,
          leading:   IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
          ),
          title:
          Row(
            children: [

              CircleAvatar(
                  radius: screenWidth / 16.5,
                  child: ClipOval(
                    child: Image.network(widget.profileURL ?? "",errorBuilder: (BuildContext context, Object exception, StackTrace? stacktrace)
                    {
                      return  CircleAvatar(
                          child: Icon(
                            Icons.person, // Display a default icon when imageUrl is null
                            color: Colors.white,
                            size: screenWidth/20,
                          )
                      );
                    },fit: BoxFit.fitWidth),
                  )
              ),

              Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child:  Text(widget.userName, style: TextStyle(
                    color: Colors.black,
                    fontSize: screenWidth /21,
                  ))),
            ],
          ),

        ),
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.white,
        body: Column(
          children: [
            Expanded(child: _buildMessageList()),
            Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Center(child: _buildMessageInput())),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {

    allMessagesStream =  _messageService.getAllMessagesStream(widget.receiverID);

    return StreamBuilder<List<QuerySnapshot>>(
      stream: allMessagesStream,
      builder: (context, snapshot) {

        if (snapshot.hasError)
        {
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

          if(document.docs.isNotEmpty){
          var messages = document.docs.map((element) => element.data() as Map<String, dynamic>);

          thisUserMessages.addAll(messages); // add messages to the list
        }

        }

        thisUserMessages.sort((a, b) => (b['Timestamp'] as Timestamp).compareTo(a['Timestamp'] as Timestamp)); //sort all the messages by their timestamp

        return ListView.builder(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          reverse: true,
          controller: _scrollController,
          itemCount: thisUserMessages.length,
          itemBuilder: (context, index) {

            return _buildMessageItem(thisUserMessages[index]);
          },
        );
        } else {
          // Handle the case where snapshot.data is null (no data available)
          return  Text('No new Messages');
        }
      },
    );
  }

  Widget _buildMessageItem(Map<String, dynamic> messageData) {

    var alignment = messageData['senderID'] == widget.receiverID;
    String timeStamp = _messageService.formatMessageTime(messageData['Timestamp']);

    //var decryptedMessage = decrypt(messageData['message'], rsaPrivateKey);

    // Return ChatBubble widget with decrypted message
    return ChatBubble(
      text: messageData['message'],
      isCurrentUser: alignment ? false : true,
      isSeen: messageData['isSeen'],
      timeStamp: timeStamp,
    );

  }



  Widget _buildMessageInput()
  {

    return Padding(
      padding: const EdgeInsets.only(left: 10, bottom: 10),
      child: Row(
        children: [
          Expanded(
              child: Form(
                key: sendMessageKey,
                child: TextFormField(
                   textAlignVertical: TextAlignVertical.center,
                   minLines: 1,
                   maxLines: 5,
                   controller: _messageController,
                   obscureText: false,
                   decoration: InputDecoration(
                   prefixIcon: IconButton(
                   icon: Icon(
                     Icons.location_on_outlined,
                     size: screenWidth/14,
                     color: Colors.black,
                   ), onPressed: () {
                   },
                   ),

                   hintText: 'Enter your message here',
                     enabledBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(20),
                       borderSide: BorderSide(
                         color: Colors.grey.withOpacity(0.5), // Change the border color to your preference
                       ),
                     ),
                     focusedBorder: OutlineInputBorder(
                       borderRadius: BorderRadius.circular(20),
                       borderSide: BorderSide(
                         color: Colors.grey.withOpacity(0.5), // Change the focused border color to your preference
                         width: 2,
                       ),
                     ),
                ),

                            ),
              ),
          ),

              Padding(
                padding: const EdgeInsets.only(bottom: 5.0),
                child: IconButton(onPressed: ()
                 {
                  if (_messageController.text.isNotEmpty && _messageController.text.contains(RegExp(r'\S'))) {
                    sendMessage();
                  }
                  _messageController.clear(); //clear the sent Text
                }, icon: const Icon(Icons.send, size: 45, color: Colors.black,)),
              ),
        ],
      ),
    );
  }

}
