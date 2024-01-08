
import 'dart:async';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:ecomodation/Messaging/messageSounds.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import '../Camera/camera.dart';
import 'chatBubble.dart';


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
  final MessageSound _messageSound = MessageSound(); //instance for message sound class
  final ScrollController _scrollController = ScrollController(); //manage scrolling of messages

  bool checkIfEmpty = false;

  late Stream<List<QuerySnapshot>> allMessagesStream; //stream to get all the messages

  @override

  void initState() {
    super.initState();
    // Initialize the stream to receive all messages
    allMessagesStream =  _messageService.getAllMessagesStream(widget.receiverID);
  }

  @override
  void dispose()
  {
    super.dispose();
    _messageController.dispose();
    _messageService.dispose();
    _scrollController.dispose();
  }


  void sendMessage() async
  {
    _messageService.sendMessage(widget.receiverID, _messageController.text); //sent the message to database

      _scrollController.animateTo(_scrollController.position.minScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut); //scroll to the new Message once the messages is sent

       _messageSound.playSound('assets/messageSentSound.mp3'); //play the sound whenever the message is sent
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
                padding: const EdgeInsets.only(right: 13),
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
           keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
           reverse: true,
           controller: _scrollController,
            itemCount: thisUserMessages.length,
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
      isCurrentUser: alignment ? false : true,
      isSeen: messageData['isSeen'],
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
                child: TextFormField(
                   textAlignVertical: TextAlignVertical.center,
                   minLines: 1,
                   maxLines: 5,
                   controller: _messageController,
                   obscureText: false,
                   decoration: InputDecoration(
                   prefixIcon: IconButton(
                   icon: Icon(
                     Icons.add,
                     size: screenWidth/14,
                     color: Colors.black,
                   ), onPressed: () async{
                     uploadOrTakeImage(context);
                   },
                   ),
                   hintText: 'Enter your message here',
                   border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(35),
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

            Padding(
                padding: const EdgeInsets.only(bottom: 45, right: 10), child:
            IconButton(onPressed: ()
             {
              if (_messageController.text.isNotEmpty && _messageController.text.contains(RegExp(r'\S'))) {
                sendMessage();
              }
              _messageController.clear(); //clear the sent Text
            }, icon: const Icon(Icons.send, size: 45, color: Colors.black,))),
      ],
    );
  }

  Future uploadOrTakeImage(BuildContext context) //Widget to display the option to display and upload image
  {
    var boxHeight = screenHeight / 5; //Adjust the size
    var cameraIconSize = boxHeight / 2.9; //Adjust the size of the Icons
    var textSize = cameraIconSize / 2.9; //Size for the text
    // var gapBetweenIcons = boxHeight;  //gap between two icons


    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: Colors.white,
              height: screenHeight, //height of the container to each device
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
                      try {
                        await availableCameras().then((value) =>
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) =>
                                    CameraUI(cameras: value))));
                      } catch (e) //Handle the case when no camera can be loaded
                          {
                        const Text(
                            'Unable to load the camera from the device'
                            //display an error on the screen
                            ,
                            style: TextStyle(
                                color: Colors
                                    .red //Set the color of the text to red.
                            ));
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        //Using a row Widget to place each icon in a row fashion
                        children: [
                          IconButton(
                              onPressed: null,
                              icon: Icon(Icons.camera_alt,
                                  size: cameraIconSize, color: Colors.black87)),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              'Camera',
                              style: TextStyle(
                                fontSize: textSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(thickness: 2, indent: screenWidth /30),
                  InkWell(
                    onTap: () {},
                    child: Row(
                        children: [
                          IconButton(
                              onPressed: null,
                              icon: Icon(Icons.image_rounded,
                                  size: cameraIconSize,
                                  color: Colors.black87)),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
                            child: Text(
                              'Gallery',
                              style: TextStyle(
                                fontSize: textSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ]),
                  ),
                  Divider(thickness: 2, indent: screenWidth / 30),
                ],
              ));
        });

  }

}
