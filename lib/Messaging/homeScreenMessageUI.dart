
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Messaging/NoMessageWidget.dart';
import 'package:flutter/material.dart';
import 'MessageService.dart';
import 'package:ecomodation/main.dart';
import 'MessageSenderInfo.dart';
import 'MessageWidget.dart';



class HomeScreenMessagingUI extends StatefulWidget {

  const HomeScreenMessagingUI({Key? key}) : super(key: key);

  @override
  State<HomeScreenMessagingUI> createState() => _HomeScreenMessagingUIState();
}

class _HomeScreenMessagingUIState extends State<HomeScreenMessagingUI> {
  final TextEditingController textController = TextEditingController();
  final MessageService _messageService = MessageService();
  Set getEachMessageSenderIDs = <String>{}; //create a Map which stores the senderID's as keys and the messageDetails in a list

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: StreamBuilder(
                  stream: _messageService.getEachMessageSenderID(),
                  builder: (context, snapshot)
                  {
                    if (snapshot.connectionState == ConnectionState.waiting)
                    {
                      return Center(
                        child: Column(
                          children:  [
                            SizedBox(height: screenHeight/40),
                            Text('Loading..', style: TextStyle(
                              fontSize: screenWidth/28,
                            ),),
                          ],
                        ),
                      );
                    }

                    else if (snapshot.hasError)
                    {
                      return Text('Error: ${snapshot.error}'); //if there is any error displaying the data, display that error
                    }

                    else if (snapshot.data!.docs.isEmpty) //if the snapshot does not have data
                    {
                      return const NoMessageWidget(); //return the NoMessageWidget if no messages were found
                    }

                    else //if the connection is successful, build the messageCards
                      {
                      for(var document in snapshot.data!.docs) //iterate through the document
                      {
                          var messageInfo = document.data();
                          getEachMessageSenderIDs.add(messageInfo['senderID']);
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Text('Inbox',
                              style: TextStyle(
                                  fontSize: screenHeight/27,
                                  fontWeight: FontWeight.bold)),
                        ),

                         Expanded(
                           child: ListView.builder
                              (
                              shrinkWrap: true,
                              itemExtent: 80.0, //space between the items in the list
                              itemCount: getEachMessageSenderIDs.length, //the no of cards displayed will be the same as the no of senderID's in the Map
                              itemBuilder: (context, index)
                              {
                                var messageInfo = getEachMessageSenderIDs.elementAt(index);

                                return displayMessageCard(messageInfo); //return the displayMessageCard widget and pass the info about each user to the card widget
                              },
                            ),
                         ),
                        ],
                      );
                      }
                  }
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget displayMessageCard(String senderID) {

    var receiverID = senderID; //The senderID of the sender now becomes the receiver ID as the message will be sent back to that user

    late final String userName;
    late final String? profileImageUrl;

    return InkWell(

       onTap: () {
         Future.delayed(Duration.zero, () async {
          //await _messageService.markMessageSeen(senderID);
           if (mounted) {
             Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDisplay(receiverID: receiverID, userName: userName, profileURL: profileImageUrl!)));
           }
         });
       },

       child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children:  <Widget>
            [
               FutureBuilder<MessageSenderInfo>(
                 future: _messageService.getSenderInfo(senderID),
                 builder: (BuildContext context, snapshot) {

                   if (snapshot.connectionState == ConnectionState.waiting) {
                     return const CircularProgressIndicator();
                   } else if (snapshot.hasError || !snapshot.hasData) {
                     return CircleAvatar(
                       radius: screenWidth / 12.5,
                       child: const Icon(Icons.person),
                     );
                   }  else {
                     userName = snapshot.data!.userName;
                     profileImageUrl = snapshot.data!
                         .profileURL;
                     return CircleAvatar(
                       radius: screenWidth / 12.5,
                       child: ClipOval(
                         child: Image.network(snapshot.data!.profileURL),
                       ),
                     );
                   }
                 },
               ),

             Expanded(
               child: Padding(
                padding: const EdgeInsets.only( left: 10),
                 child: Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>
                     [
                        FutureBuilder<MessageSenderInfo>(
                          future: _messageService.getSenderInfo(senderID),
                          builder: (BuildContext context, snapshot) {
                                return Text( snapshot.data?.userName ?? 'No Name',style: TextStyle(
                                    fontSize: screenWidth/25,
                                    fontWeight: FontWeight.bold
                                )
                                );
                              }
                          ),

                      const SizedBox(height: 10),// Text for the User name
                      StreamBuilder(
                        stream: _messageService.getLastSentMessage(senderID),
                        builder: (context, snapshot) {

                          if(!snapshot.hasData || snapshot.hasError)
                            {
                              return const Text("");
                            }
                        else
                          {
                            List<QuerySnapshot> snapshotList = snapshot.data!;
                            Map<String, bool> storeLastMessage = {};
                            DateTime receivedMessageTimestamp = snapshotList.first.docs.isNotEmpty ? (snapshotList.first.docs.first.data() as Map<String, dynamic>)['Timestamp'].toDate() : DateTime(0);
                            DateTime sentMessageTimestamp = snapshotList.last.docs.isNotEmpty ? (snapshotList.last.docs.last.data() as Map<String, dynamic>)['Timestamp'].toDate() : DateTime(0);
                            // if the characters increase more than the given space, display the rest by '....'
                            if(receivedMessageTimestamp.isAfter(sentMessageTimestamp))
                              {
                                var messageInfo = snapshotList.first.docs.first.data() as Map<String, dynamic>;
                                storeLastMessage[messageInfo['message']] = true;
                            //   _messageService.markMessageSeen(senderID,  snapshotList.first.docs.first.id);
                              }
                            else if(receivedMessageTimestamp.isBefore(sentMessageTimestamp))
                              {
                                var messageInfo = snapshotList.last.docs.last.data() as Map<String, dynamic>;
                                storeLastMessage[messageInfo['message']] = false;

                              }

                              var lastMessage = storeLastMessage.keys.first;

                            return Text(storeLastMessage.values.contains(true) ? lastMessage : "You: $lastMessage", maxLines: 1 );
                            //return  Text(lastSentMessages.first.length > screenWidth - 350 ? '${lastSentMessages.first.substring(0, 40)}....' : lastSentMessages.first, maxLines: 1,);
                          }
                        }

   ),
                    const Padding(
                         padding: EdgeInsets.only(top: 5),
                         child:  Divider())// Text for the last sentMessage by the user
                     ]
             ),
               )),

          ]
        ),

      ),
    );

  }




}


