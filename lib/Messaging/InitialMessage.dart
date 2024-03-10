
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
            child: IconButton(
              onPressed: () async {
                if (sendMessageKey.currentState!.validate()) {
                  sendMessage(); // Send the message to the user

                  await _messageSerivce.sendInitialMessageInfo(widget.detailedListingsStore); // Update the Listing

                  if (mounted) {
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
              icon: Icon(
                Icons.send, // Icon for sending
                size: screenWidth/7.5, // Adjust the icon size as needed
              ),
              color: Colors.black, // Adjust the icon color
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
                cursorColor: Colors.black,
                maxLength: 200,
                maxLines: 5,
                controller: _messageController,
                obscureText: false,
                decoration: InputDecoration(
                  hintText: 'Enter your message here',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5), // Change the border color to your preference
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: Colors.grey.withOpacity(0.5), // Change the focused border color to your preference
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.red, // Change the error border color to your preference
                      width: 2,
                    ),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.red, // Change the focused error border color to your preference
                      width: 2,
                    ),
                  ),
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
