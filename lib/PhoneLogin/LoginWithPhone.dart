import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../phoneLogin/OTPpage.dart';

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

  Widget phoneTextForm(BuildContext context)
  {
    return SizedBox(
      width: screenWidth - 20,
      child: TextFormField(
          keyboardType: TextInputType.number, //Make sure the keyboard opened is the number
          maxLength: 10,
          cursorColor: colorTheme,
          cursorWidth: 4,
          controller: phone, //keyboardType: TextInputType.text,
          decoration:  InputDecoration(//For decorating the TextForm box
            hintStyle: const TextStyle(
              fontSize: 18, // Size of the hintText
            ),

            helperText: 'Enter your phone number ', //hintText

              border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(5),
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
    );
  }

  /*--------------------- Build the login button ----------------- */

  Widget _loginButton(BuildContext context)
  {
    return ElevatedButton(
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(15),
            )),
        fixedSize: MaterialStateProperty.all(const Size(160, 45)),
        backgroundColor: const MaterialStatePropertyAll(
            Colors.black), //set the color for the continue button
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
