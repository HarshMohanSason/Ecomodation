import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'homeScreenUI.dart';
import 'package:firebase_auth/firebase_auth.dart';


bool loggedInWithPhone = false; //set to true since user has been logged in
class OtpUI extends StatefulWidget {

  final String verificationId;  //get the verification Id.
  const OtpUI({Key? key, required this.verificationId}) : super(key: key);

  @override
  State<OtpUI> createState() => _OtpUIState();
}


class _OtpUIState extends State<OtpUI> {
  bool submit = false;
  final _formkeyOTP = GlobalKey<FormState>();   //key for the OTP
  FirebaseAuth auth = FirebaseAuth.instance;

  final otp_pin = TextEditingController(); //Control the text for the OTP

  final defaultPinTheme = PinTheme(
    width: 58,
    height: 58,
    textStyle: const TextStyle(fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(22),
    ),
  );

  void  checkOTP () async {  //Function to check the OTP

    if(_formkeyOTP.currentState!.validate()) {  //if the form is validated correctly,

      try{
        //create a PhoneAuthCredential
        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: otp_pin.text);
        await auth.signInWithCredential(credential); //sign in the user with credential
        loggedInWithPhone = true; //set to true since user has been logged in
        //if the sign is successful, navigate the user to the main screen.
        Navigator.push(context, MaterialPageRoute(builder: (_) =>  HomeScreenUI()));
        }
      catch (e)  //catch any errors if the login is not successful.
      {
       //   print('Error: $e'); //Print the error here
       }

    }

  }


  @override
  Widget build(BuildContext context) {

    return  WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor:   colorTheme, //set the background color
            body: SingleChildScrollView(
            child:  _otpForm(context),   //call the _OTPform widget here.
            ),
          ),
    );

  }

  Widget _otpForm(BuildContext context)
  {
    return Form(
      key: _formkeyOTP,
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Enter your Verification Code',
                    textStyle : const TextStyle(
                      fontSize: 27,
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
            ),
          ),
          const  SizedBox(height: 280),
          Align(
              alignment: Alignment.center,
              child: _pinInputUI(context),
          ),

          const SizedBox(height: 60),

          _submitButton(context),
        ],
      )

    );
  }



  /*------------------------ Widget for building the Pinput UI ------------------------------*/

  Widget _pinInputUI(BuildContext context)
  {
    return Pinput(
        controller: otp_pin,
        length: 6, //Length for the OTP being entered
        defaultPinTheme: defaultPinTheme, //Pinput theme
        validator: (value)
        {
          final nonNumericRegExp = RegExp(r'^[0-9]');
          if(value!.isEmpty == true)
          {
            return 'OTP cannot be empty';
          }
          //check if the number isWithin 0-9 and is lowercase
          else  if (!nonNumericRegExp.hasMatch(value))
          {

            return 'OTP can only contain digits';  //return error if it doesn't match the REGEXP
          }
          else if  (value.length < 6)
          {
            return 'OTP should be 6 digit number';
          }
          return null;
        }
    );
  }



  /*------------------------------Widget for building the submit button ----------------------*/
  Widget _submitButton(BuildContext context)
  {
    return ElevatedButton(
      onPressed: () => checkOTP(),
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        fixedSize: MaterialStateProperty.all(const Size(160,55)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            )
        ),
        elevation: MaterialStateProperty.all(18),
        shadowColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
      child: const Text('Submit',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
    );
  }
}
