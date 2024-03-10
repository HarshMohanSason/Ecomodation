
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:ecomodation/homeScreenUI.dart';
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
  final formKeyOTP = GlobalKey<FormState>();   //key for the OTP
  FirebaseAuth auth = FirebaseAuth.instance;

  final otpPin = TextEditingController(); //Control the text for the OTP

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

    if(formKeyOTP.currentState!.validate()) {  //if the form is validated correctly,

      try{
        //create a PhoneAuthCredential
        PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: widget.verificationId, smsCode: otpPin.text);
        await auth.signInWithCredential(credential); //sign in the user with credential
        loggedInWithPhone = true; //set to true since user has been logged in
        //if the sign is successful, navigate the user to the main screen.
        if(mounted)
        {
          Navigator.push(context, MaterialPageRoute(builder: (_) =>  HomeScreenUI()));
        }
      }
      catch (e)  //catch any errors if the login is not successful.
      {
       //   print('Error: $e'); //Print the error here
       }

    }

  }


  @override
  Widget build(BuildContext context) {

    return  PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorTheme, //set the background color
            body: _otpForm(context),
          ),
    );

  }

  Widget _otpForm(BuildContext context)
  {
    return Form(
      key: formKeyOTP,
      child: Column(
        children: [
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.only(top: 100),
              child: AnimatedTextKit(
                animatedTexts: [
                  TyperAnimatedText('Enter Your Verification Code',
                    textStyle : TextStyle(
                      fontSize: screenWidth/16.5,
                      fontWeight: FontWeight.bold,
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
          Padding(
            padding: EdgeInsets.only(top: screenWidth/2),
            child: Center(child: _pinInputUI(context)),
          ),

          Spacer(),

          Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: _submitButton(context)),
        ],
      )

    );
  }



  /*------------------------ Widget for building the Pinput UI ------------------------------*/


  Widget _pinInputUI(BuildContext context) {

    return SizedBox(
      width: screenWidth - 20,
      child: Pinput(
          controller: otpPin,
          length: 6, // Length for the OTP being entered
          defaultPinTheme: PinTheme(
            width: 80,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(
                  21), // Adjust the border radius as needed
            ),
            textStyle: TextStyle(
              fontSize: screenWidth / 14.5,
              color: Colors.black, // White text color for better visibility
              fontWeight: FontWeight.bold,
            ),
          ),
          errorTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          onSubmitted: (value)
          {
            setState(() {
              value = otpPin.text;
            });
          },
          validator: (value) {
            final nonNumericRegExp = RegExp(r'^[0-9]');
            if (value!.isEmpty == true) {
              return 'OTP cannot be empty';
            }
            //check if the number isWithin 0-9 and is lowercase
            else if (!nonNumericRegExp.hasMatch(value)) {
              return 'OTP can only contain digits'; //return error if it doesn't match the REGEXP
            } else if (value.length < 6) {
              return 'OTP should be 6 digit number';
            }
            return null;
          }),
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
        fixedSize: MaterialStateProperty.all( Size(screenWidth/1.5, screenHeight/16)),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            )
        ),
        elevation: MaterialStateProperty.all(18),
        shadowColor: MaterialStateProperty.all<Color>(Colors.black),
      ),
      child:  Text('Submit',
          style: TextStyle(
            fontSize: screenWidth/22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          )),
    );
  }
}
