
import 'LoginWithPhone.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'OTPpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class PhoneSignupInfo extends StatefulWidget {
  const PhoneSignupInfo({Key? key}) : super(key: key);

  @override
  State<PhoneSignupInfo> createState() => _UserInfoDetails(); //create the state
}

class _UserInfoDetails extends State<PhoneSignupInfo> {  //create stateful class which will take the userInfo


  final _phoneNoController = TextEditingController();  //control the text being edited in the phone number textform
  final _usernameController = TextEditingController(); //control the text being edited in the username textform

  FirebaseAuth auth = FirebaseAuth.instance;  //Name the instance as auth
  CollectionReference writeUserInfo = FirebaseFirestore.instance.collection('userInfo'); //create an instance to write data to firebase
  CollectionReference<Map<String, dynamic>>  readUserInfo = FirebaseFirestore.instance.collection('userInfo'); //create an instance to read data from firebase

  bool displayErrorUserExists = false; //flag to set if the userexists, then display the error;
  bool displayErrorPhoneNoExists = false;

  final _formKey = GlobalKey<FormState>(); //key for the form.

  Future <void> navigateToOTPUI(BuildContext context) async   //This function will take the User to the OTP verification page
      {
    if(_formKey.currentState!.validate()) {            //if the form is validated
      try{
        var document =  await readUserInfo.get(); //get the documents from the collection reference
        bool userExists = false;
        for(var documentVal in document.docs)
        {
          Map<String, dynamic> data = documentVal.data(); //get the data from each document;

          if(data['username'] == _usernameController.text || data['phonenumber'] == _phoneNoController.text)
          {
            userExists = true;
            if(phoneLoginDocID.isEmpty)
            {
              phoneLoginDocID = documentVal.id;
              await storage.write(key: 'phoneLoginDocID ', value: phoneLoginDocID);
            }
            break;
          }

        }

        if(userExists == true) //if userExists
            {
          setState(() {
            displayErrorUserExists = true;  //set the flag to display error to be true
            displayErrorPhoneNoExists = true;
          });

        }
        else //if user does not exists, prompt to enter the OTP
            {
          var newPhoneLoginUser = await writeUserInfo.add({'username': _usernameController.text, 'phonenumber' :  _phoneNoController.text}); //add the data to the database
          phoneLoginDocID = newPhoneLoginUser.id; //store the documentID for login with phone to update the listing later
          await storage.write(key: 'phoneLoginDocID ', value: phoneLoginDocID);
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
      catch(e){ 
        Center(child: Text("Could Not login" + '$e'));
      }
      
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,

      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),  //set the background color to white
        body: SingleChildScrollView(
          child: _enterinfo(context),
        ),
        ),
    );
  }

  Widget _enterinfo(BuildContext context) //Widget to build the Enterinfo where user will enter all the details
  {

    return Form(    //Return the form widget
      key: _formKey,  // key for the form.
      child: Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,

          children: [

            Align(
              alignment: Alignment.topLeft,
              child: IconButton (
                  onPressed: () {
                    Navigator.pushNamed(context, 'AppIntroUI');
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
              ),
            ),

            AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText('Let\'s get you started',
                  textStyle : const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  speed: const Duration(milliseconds: 100),
                ),
              ],
              totalRepeatCount: 1,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),

            const SizedBox(height: 60),

            const Padding(
              padding: EdgeInsets.only(left: 15, bottom : 15),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: Text('Create an Account', style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),)),
            ),

            SizedBox(
              width: screenWidth - 20,
              child: TextFormField(
                  controller: _usernameController,
                  maxLength: 18,
                  cursorColor: Colors.black,
                  cursorWidth: 2,
                  decoration:  InputDecoration(   //For decorating the TextForm box
                    hintStyle: const TextStyle(
                      fontSize: 18, // Size of the hintText
                    ),
                    helperText: 'Enter your username ', //hintText
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
                    final containAlpha = RegExp(r'^[a-z]');
                    if(containAlpha.hasMatch(text) == false)
                      {
                        return 'Username needs to contain at least one alphabet';
                      }
                    return null;
                  }

              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: screenWidth - 20,
              child: TextFormField(
                  keyboardType: TextInputType.number, //Make sure the keyboard opened is the number
                  maxLength: 10,
                  cursorColor: Colors.black,
                  cursorWidth: 2,
                  controller: _phoneNoController,
                  //keyboardType: TextInputType.text,
                  decoration:  InputDecoration(//For decorating the TextForm box
                    hintStyle: const TextStyle(
                      fontSize: 18, // Size of the hintText
                    ),
                    helperText: 'Enter your phone number ', //hintText
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
            ),
            if(displayErrorPhoneNoExists == true || displayErrorUserExists == true) //If true
              const Padding(
                padding: EdgeInsets.only(left: 10, top: 10),
                child:  Text('There is already an account associated with this phone number or username',  //Display the error
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 14.5,
                    )),
              ),

            Padding(
              padding: const EdgeInsets.only(top: 50),
              child: ElevatedButton(
                style:  ButtonStyle(
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
                      )),
                  fixedSize: MaterialStateProperty.all(const Size(180,40)),
                  backgroundColor: MaterialStateProperty.all(Colors.black), //set the color for the continue button
                ),

                onPressed: () => navigateToOTPUI(context), //Once added, navigate to the OTP screen to get the OTP
                child: const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorTheme,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}