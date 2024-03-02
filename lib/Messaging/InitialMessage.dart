
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import '../Listings/AskButtonState.dart';
import '../main.dart';
import 'MessageService.dart';

class InitialMessageWidget extends StatefulWidget {

  final String receiverID;
  final DetailedListingsStore detailedListingsStore;

  const InitialMessageWidget({Key? key, required this.receiverID, required this.detailedListingsStore}) : super(key: key);

  @override
  State<InitialMessageWidget> createState() => _InitialMessageWidgetState();
}

class _InitialMessageWidgetState extends State<InitialMessageWidget> {
  late DetailedListingStateManage showAskButtonState;
  final TextEditingController _messageController = TextEditingController();
  final MessageService _messageSerivce = MessageService();
  final GlobalKey<FormState> sendMessageKey = GlobalKey<FormState>();
  //create instance of the addListingState here.
  bool checkIfEmpty = false;


  @override

  void initState() {
    super.initState();

    // Initialize the stream to receive all messages
  }

  void sendMessage() async
  {
    try {
      if (_messageController.text.isNotEmpty) {

        await _messageSerivce.sendMessage(widget.receiverID, _messageController.text);
       await _messageSerivce.createIsOnlineVal(widget.receiverID);
      }
    }
    catch(e)
    {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      //appBar: AppBar(title: const Text('') ,
      backgroundColor: Colors.white,
      body: Column(

        children: [

          //   Expanded(child: _buildMessageList()),

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

          Padding(
              padding: const EdgeInsets.only(top: 50, right: 13),
              child: Center(child: _buildMessageInput())),

          Text('Note: You can only send the initial message once',
            style: TextStyle(
              fontSize: screenWidth/30,
              fontWeight: FontWeight.bold,
            ),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.only(bottom: 40),
            child: ElevatedButton(onPressed: () async {

              if(sendMessageKey.currentState!.validate())
              {
                sendMessage();//send the message to the user

                await  _messageSerivce.sendInitialMessageInfo(widget.detailedListingsStore); //update the Listing

                if(mounted)
                  {
                    Navigator.pushNamed(context, 'HomeScreen');
                    Fluttertoast.showToast(
                      msg: 'Your Initial Message has been sent!',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.white,
                      textColor: Colors.black,
                    );
                  }
              }
            },
                style: ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20.0), // Adjust the radius as needed
                      )),
                  fixedSize: MaterialStateProperty.all( Size(screenWidth - 60,40)),
                  backgroundColor: const MaterialStatePropertyAll(Colors.black),
                  foregroundColor: const MaterialStatePropertyAll(Colors.white),
                ),
                child: Text('Send',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth/24,
                  ),)
            ),
          ),
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
            child: Form(
              key: sendMessageKey,
              child: TextFormField(
                maxLength: 200,
                maxLines: 5,
                controller: _messageController,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Enter your message here',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(   //decorate the border of the box
                      width: 8,
                      style: BorderStyle.solid,  //style of the border
                      color: Color(0x000000FF),  //color of the borderlines
                    ),
                  ) ,
                ),
                validator: (value) {
                  if(value?.isEmpty == true)
                  {
                    return 'The message cannot be empty';
                  }
                },
              ),
            ),
          ),
        ),

        /*  Padding(padding: const EdgeInsets.only(bottom: 50, right: 10), child:
            IconButton(onPressed: () => sendMessage(), icon: const Icon(Icons.send, size: 45, color: colorTheme,))),

       */
      ],
    );
  }

}
