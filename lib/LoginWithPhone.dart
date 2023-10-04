import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'OTPpage.dart';

String phoneLoginDocID = ''; //Get the documentID for the PhoneLogin

class LoginWithPhone extends StatefulWidget {
   const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();

}

class _LoginWithPhoneState extends State<LoginWithPhone>
{
 //Store the document id in this variable
  final _loginphone = GlobalKey<FormState>(); //key for the form.
  final phone = TextEditingController(); //Control the phone number entered in the textform field
 // bool loginsuccess = false; //bool variable to set state for login
  FirebaseAuth auth = FirebaseAuth.instance;


  bool phoneNumberValidated = true;

  Future<void> verifyForm(BuildContext context) async { //Verify form which checks the form, reads data from the database and logs user in with their phone number
    final readUserInfo = FirebaseFirestore.instance.collection('userInfo'); //create instance referring to the userinfo at database

    if (_loginphone.currentState!.validate()) {  //if the form is validated t

      try {
        var querySnapshot = await readUserInfo.get(); //get the snapshot of the data in userInfo
        bool phoneNumberExists = false; // flag to set true if the phone number is found

        for (var documentSnapshot in querySnapshot.docs) //loop through each document
        {
          Map<String, dynamic> data = documentSnapshot.data(); //get the document data
          var phoneNumber = data['phonenumber']; //store the phoneNumber in the variable

          if (phoneNumber == phone.text )
          {
            phoneLoginDocID = documentSnapshot.id;
            phoneNumberExists = true; //  When the phone number matched, set the flag to true
            break; //break the loop
          }
        }

        if (phoneNumberExists) {
          // Phone number matched, proceed with login
          await auth.verifyPhoneNumber(  //Verify the user provided phone number

              phoneNumber: '+91${phone.text}',  //Get the phone number

              verificationCompleted: (PhoneAuthCredential credential) async {   //if verification is completed, sign in
                await auth.signInWithCredential(credential).then((value) => {
                  // print("You are logged in"),
                });
              },

              verificationFailed: (FirebaseAuthException e) async {
                // print(e.message);//if verification is failed, print the error
              },

              codeSent: (String verificationId, int? resendToken) async {

                //send the OTP code.
                Navigator.push(context, MaterialPageRoute(builder: (context) =>  OtpUI(verificationId : verificationId))); // Navigate the User to the OTP page to prompt them to enter the OTP
                //  PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId, smsCode: smsCode);

              },
              codeAutoRetrievalTimeout: (String verificationId) {
              }
          );

        }

        else {
          // Phone number not found, display error message
          setState(() {
         phoneNumberValidated = false;
          });
        }
      } catch (e) {  //catch any error statement and print it
       //  print('Error querying user info: $e');
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(children: <Widget>[
          phoneloginform(context) //call the phone login form in the body
        ]),
      ),
    );
  }

  Widget phoneloginform(BuildContext context)  //Build the phone login form
  {
    return Form(
       key: _loginphone,  //key for the loginphone
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(  //Put all the textform fields in a column widget
              children: <Widget> [
                Align(
                  alignment: const Alignment(-1,-0.8),
                  child: IconButton (
                      onPressed: () {
                        Navigator.pushNamed(context, 'AppIntroUI');
                      },
                      icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
                  ),
                ),
                SizedBox(height: 20),
                _phonetextform(context),//Call the phone textform

                if(!phoneNumberValidated)   //Return an error if no account is associated with the phone number entered
                const Text('No account associated with this phone number',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                )),

                const SizedBox(height: 40),

                _loginButton(context), //call the login button
              ],
          ),
        ),

    );
  }


  /*--------------------- Build the text field form for entering the phone number----------------- */

  Widget _phonetextform(BuildContext context)
  {
    return TextFormField(
        keyboardType: TextInputType.number, //Make sure the keyboard opened is the number
        maxLength: 10,
        cursorColor: colorTheme,
        cursorWidth: 4,
        controller: phone, //keyboardType: TextInputType.text,
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
    );
  }

  /*--------------------- Build the login button ----------------- */

  Widget _loginButton(BuildContext context)
  {
    return ElevatedButton(
      style: ButtonStyle(
        fixedSize: MaterialStateProperty.all(const Size(160, 40)),
        backgroundColor: const MaterialStatePropertyAll(
            colorTheme), //set the color for the continue button
      ),
      onPressed: () async {
      await verifyForm(context);
      },
      child: Text(
        'Login',
        style: TextStyle(
          fontSize: 18 * (screenHeight/ 932),
          color: const Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
