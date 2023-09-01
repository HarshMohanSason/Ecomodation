
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'OTPpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'AddListing.dart';


class PhoneSignupInfo extends StatefulWidget {
  const PhoneSignupInfo({Key? key}) : super(key: key);

  @override
  State<PhoneSignupInfo> createState() => _UserInfoDetails(); //create the state
}

class _UserInfoDetails extends State<PhoneSignupInfo> {  //create stateful class which will take the userInfo

  final _phoneNoController = TextEditingController();  //control the text being edited in the phone number textform
  final username = TextEditingController(); //control the text being edited in the username textform

  FirebaseAuth auth = FirebaseAuth.instance;  //Name the instance as auth
  CollectionReference writeUserInfo = FirebaseFirestore.instance.collection('userInfo'); //create an instance to write data to firebase
  var readUserInfo = FirebaseFirestore.instance.collection('userInfo'); //create an instance to read data from firebase


  bool displayerrorUnameexists = true; //flag to set if the userexists, then display the error;
  bool displayerrorPhnoexists = true;

  final _formKey = GlobalKey<FormState>(); //key for the form.

  Future <void> navigateToOTPUI(BuildContext context) async   //This function will take the User to the OTP verification page
  {


       if(_formKey.currentState!.validate()) {            //if the form is validated
         try{
           var document =  await readUserInfo.get(); //get the documents from the collection reference
           bool userexists = false;
           for(var documentval in document.docs)
             {
               Map<String, dynamic> data = documentval.data(); //get the data from each document;
               var uname = data['username']; //store the username
               var phno = data['phonenumber']; //store the phone number

               if(uname == username.text && phno == _phoneNoController.text)
                 {
                   userexists = true;
                   break;
                 }
             }
           if(userexists) //if userexists
             {
              setState(() {
                displayerrorUnameexists = false;  //set the flag to display error to be true
                displayerrorPhnoexists = false;
              });
             }
           else //if user does not exists, prompt to enter the OTP
             {
             writeUserInfo.add({'username': username.text, 'phonenumber' :  _phoneNoController.text}); //add the data to the database
               await auth.verifyPhoneNumber(  //Verify the user provided phone number

                   phoneNumber: '+91${_phoneNoController.text}',  //Get the phone number

                   verificationCompleted: (PhoneAuthCredential credential) async {   //if verification is completed, sign in
                     await auth.signInWithCredential(credential).then((value) => {
                       // print("You are logged in"),
                     });
                   },

                   verificationFailed: (FirebaseAuthException e) async {
                     // print(e.message);//if verification is failed, print the error
                   },

                   codeSent: (String verificationId, int? resendToken) async {  //send the OTP code.
                     Navigator.push(context, MaterialPageRoute(builder: (context) =>  OtpUI(verificationId: verificationId)));
                     //  PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

                   },
                   codeAutoRetrievalTimeout: (String verificationId) {
                   }
               );

             }

         }
         catch(e){ //to catch any error during the process.
         //  print('Error: $e');
         }


      //check if the form is validated
     // push to the OTP page if it is
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,

      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),  //set the background color to white
        body: SingleChildScrollView(   // Put everything in singlechild scroll view to make sure no pixel overflow error occures
        child: Column(                  //Prevent the pixel overflowing error on the bottom of the screen.
          children: [
            _enterinfo(context),  //call the _Enterinfo widget here.
          ],
        ),
        ),
      ),
    );
  }

  Widget _enterinfo(BuildContext context) //Widget to build the Enterinfo where user will enter all the details
  {

    return Form(    //Return the form widget
      key: _formKey,  // key for the form.
      child: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: Column(

          mainAxisAlignment: MainAxisAlignment.start, //Align all the child widgets of the column to center
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Align(
              alignment: const Alignment(-1,-0.8),
              child: IconButton (
                  onPressed: () {
                    Navigator.pushNamed(context, 'AppIntroUI');
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
              ),
            ),

            Align(
              alignment: Alignment.topCenter,
              child: Image.asset('assets/house.png',
              ),
            ),

            const SizedBox(height: 30),
              AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText('Let\'s get you started',
                  textStyle : const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Merriweather',
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),

            const SizedBox(height: 30),

           TextFormField(
              controller: username,
              maxLength: 18,
              cursorColor: const Color(0xFF0BC25F),
              cursorWidth: 4,
              decoration:  InputDecoration(   //For decorating the TextForm box
                hintStyle: const TextStyle(
                  fontSize: 18, // Size of the hintText
                ),
                hintText: 'Enter your username ', //hintText
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(   //decorate the border of the box
                    width: 10,
                    style: BorderStyle.solid,  //style of the border
                    color: Color(0xFF0BC25F),  //color of the borderlines
                  ),
                ),
              ),
               validator: (text ) {
                  if (text!.isEmpty) {
                    return 'Please enter a valid username';
                  }

                  final nonNumericRegExp = RegExp(r'^[0-9a-z]+$');  //check if the number isWithin 0-9 and is lowercase
                  if (!nonNumericRegExp.hasMatch(text)) {
                    return 'Username can only contain digits and lowercase letters';  //return error if it doesn't match the REGEXP
                  }
                  return null;
                }

            ),
            const SizedBox(height: 20),

            TextFormField(
                keyboardType: TextInputType.number, //Make sure the keyboard opened is the number
                maxLength: 10,
                cursorColor: const Color(0xFF0BC25F),
                cursorWidth: 4,
                controller: _phoneNoController,

              //keyboardType: TextInputType.text,
              decoration:  InputDecoration(//For decorating the TextForm box
                hintStyle: const TextStyle(
                  fontSize: 18, // Size of the hintText
                ),
                hintText: 'Enter your phone number ', //hintText

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(   //decorate the border of the box
                    width: 8,
                    style: BorderStyle.solid,
                    //style of the border
                    color: Color(0x000000FF),  //color of the borderlines
                  ),
                ),
              ),

                validator: (text) {
                  final nonNumericRegExp = RegExp(r'^[0-9]+$'); //RegExp to match the phone number
                  if (text!.isEmpty) { //return an error if the textform is not empty
                    return 'Please enter a valid phone number';
                  }
                  //check if the number isWithin 0-9.
                   if (!nonNumericRegExp.hasMatch(text)) {
                    return 'Phone number must contain only digits'; //
                  }
                  if (text.length < 10) //Make sure the number is a total of 10 digits.
                      {
                    return 'Number should be a ten digit number';
                  }
                  return null;
                }
            ),

            if(!displayerrorPhnoexists) //If true
            const Text('There is already an account associated with this phone number',  //Display the error
            style: TextStyle(
              color: Colors.red,
              fontSize: 14,
            )),

            const SizedBox(height: 40),

             ElevatedButton(
              style:  ButtonStyle(
               fixedSize: MaterialStateProperty.all(const Size(160,40)),
                backgroundColor: MaterialStateProperty.all(colorTheme), //set the color for the continue button
              ),

              onPressed: () => navigateToOTPUI(context), //Once added, navigate to the OTP screen to get the OTP
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
