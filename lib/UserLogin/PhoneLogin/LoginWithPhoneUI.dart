import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../phoneLogin/OTPpageUI.dart';

String phoneLoginDocID = ' '; //Get the documentID for the PhoneLogin

class LoginWithPhone extends StatefulWidget {
   const LoginWithPhone({Key? key}) : super(key: key);

  @override
  State<LoginWithPhone> createState() => _LoginWithPhoneState();

}

class _LoginWithPhoneState extends State<LoginWithPhone>
{

  final _phoneLoginKey = GlobalKey<FormState>(); //key for the form.
  final phone = TextEditingController(); //Control the phone number entered in the textForm field
  bool phoneNumberValidated = true; //Flag to check whether the phone number is validated or not

  Future<void> verifyForm(BuildContext context) async { //Verify form which checks the form, reads data from the database and logs user in with their phone number

    if (_phoneLoginKey.currentState!.validate()){  //check if the form is validated or not

      try {
        var querySnapshot = await FirebaseFirestore.instance.collection('userInfo').where('phonenumber', isEqualTo: phone.text).get();  //get the snapshot of the data in userInfo
        bool userExists = false;

        if(querySnapshot.docs.isNotEmpty)
          {
            phoneLoginDocID = querySnapshot.docs.first.id;
            userExists = true; // When the phone
          }

        if (userExists && mounted) {

          await storage.write(key: 'phoneLoginDocID', value: phoneLoginDocID);
          await FirebaseAuth.instance.verifyPhoneNumber(  //Verify the user provided phone number

              phoneNumber: '+1${phone.text}',  //Get the phone number

              verificationCompleted: (PhoneAuthCredential credential) async {   //if verification is completed, sign in
                await FirebaseAuth.instance.signInWithCredential(credential).then((value) => {
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

      }
      catch (e) {
        //catch any error statement and print it
       //  print('Error querying user info: $e');
      }
    }
  }


  @override
  void dispose()
  {
    super.dispose();
    phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Column(children: <Widget>[
          phoneLoginForm(context) //call the phone login form in the body
        ]),
      ),
    );
  }

  Widget phoneLoginForm(BuildContext context)  //Build the phone login form
  {
    return Form(
       key: _phoneLoginKey,  //key for the loginPhoneForm
        child: Padding(
          padding: const EdgeInsets.only(top: 70),
          child: Column(  //Put all the textForm fields in a column widget
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
               const SizedBox(height: 20),
                phoneTextForm(context),//Call the phone textform

                if(!phoneNumberValidated)...
                [
                  //Return an error if no account is associated with the phone number entered
                  const Text('No account associated with this phone number',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                )),
              ],
                const SizedBox(height: 40),

                _loginButton(context), //call the login button
              ],
          ),
        ),

    );
  }


  /*--------------------- Build the text field form for entering the phone number----------------- */
  Widget phoneTextForm(BuildContext context) {
    return SizedBox(
      width: screenWidth - 20,
      child: TextFormField(
        keyboardType: TextInputType.number,
        maxLength: 10,
        cursorColor: Colors.black,
        cursorWidth: 2,
        controller: phone,
        style: TextStyle(
          fontSize: screenWidth/20,
          color: Colors.black, // Change the text color to your preference
        ),
        decoration: InputDecoration(
          hintText: '+91',
          hintStyle: TextStyle(
            fontSize: screenWidth/20,
            color: Colors.grey, // Change the hint text color to your preference
          ),
          helperText: 'Phone Number',
          helperStyle: TextStyle(
            fontSize: screenWidth/25,
            color: Colors.grey, // Change the helper text color to your preference
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5), // Change the border color to your preference
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.5), // Change the focused border color to your preference
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.red, // Change the error border color to your preference
              width: 2,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide(
              color: Colors.red, // Change the focused error border color to your preference
              width: 2,
            ),
          ),
        ),
        validator: (text) {
          final nonNumericRegExp = RegExp(r'^[0-9]+$');
          if (text!.isEmpty) {
            return 'Please enter a valid phone number';
          }
          if (!nonNumericRegExp.hasMatch(text)) {
            return 'Phone number must contain only digits';
          }
          if (text.length < 10) {
            return 'Number should be a ten digit number';
          }
          return null;
        },
      ),
    );
  }


  /*--------------------- Build the login button ----------------- */

  Widget _loginButton(BuildContext context)
  {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10),
            )),
        fixedSize: MaterialStateProperty.all(Size(screenWidth/1.5, screenHeight/18)),
        backgroundColor: const MaterialStatePropertyAll(
            Colors.black), //set the color for the continue button
      ),
      onPressed: () async {
      await verifyForm(context);
      },
      child: Text(
        'Login',
        style: TextStyle(
          fontSize: screenWidth/23,
          color: const Color(0xFFFFFFFF),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
