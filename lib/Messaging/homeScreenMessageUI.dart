import 'package:ecomodation/Messaging/MessageWidget.dart';
import 'package:ecomodation/Messaging/NoMessageWidget.dart';
import 'package:flutter/material.dart';
import 'MessageService.dart';
import 'package:ecomodation/main.dart';

class HomeScreenMessagingUI extends StatefulWidget {
  const HomeScreenMessagingUI({Key? key}) : super(key: key);

  @override
  State<HomeScreenMessagingUI> createState() => _HomeScreenMessagingUIState();
}

class _HomeScreenMessagingUIState extends State<HomeScreenMessagingUI> {

  final MessageService _messageService = MessageService();
   Set getEachMessageSenderIDs = <String>{}; //create a Map which stores the senderID's as keys and the messageDetails in a list

  @override

  Widget build(BuildContext context)
  {

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [

          Padding(
            padding: const EdgeInsets.only(top: 60),
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
                      String senderID = messageInfo['senderID']; //get the sender ID

                      getEachMessageSenderIDs.add(senderID); //add the total senderID's here
                    }


                    return Column(
                      children: [

                      Align(
                      alignment: const Alignment(0,0),
                      child: Text('Messages',
                          style: TextStyle(
                              fontSize: screenHeight/27,
                              fontWeight: FontWeight.bold)),
                        ),
                       Divider(color: Colors.black,),


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
    );
  }


  Widget displayMessageCard(String senderID) {
    var receiverID = senderID; //The senderID of the sender now becomes the receiver ID as the message will be sent back to that user

    return GestureDetector(

      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDisplay(receiverID: receiverID)));
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children:  <Widget>
              [
                 CircleAvatar(
                   radius: screenWidth/12.5,
                  child: Icon(Icons.person),
                ),

               Expanded(
                 child: Padding(
                  padding: EdgeInsets.only( left: 10),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>
                       [
                          Text("Sourav Dhankar",style: TextStyle(
                            fontSize: screenWidth/25,
                            fontWeight: FontWeight.bold
                          )),
                        SizedBox(height: 10,),// Text for the User name
                         Text("Hello there"),
                        SizedBox(height: 10),// Text for the last sentMessage by the user
                        Divider(color: Colors.black,),    ]
               ),
                 )),

            ]
          )
        ),

      ),
    );


    /*Center(
        child: Card(
          color: Colors.white,
         // margin: EdgeInsets.symmetric(horizontal: screenWidth - 420, vertical: screenHeight - 800),
          //shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: InkWell(
            onTap: ()
            {
            ;
            },
            child:  ListTile(
              leading:  CircleAvatar(radius: screenWidth/3,child: Icon(Icons.person)),
              title: Text('Wow'), // will change this later as well
             // subtitle: Text('hello'), //Gonna change later
            ),
          ),
        ),
      );

       */
  }

}


