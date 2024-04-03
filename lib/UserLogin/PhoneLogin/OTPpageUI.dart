import 'dart:async';
import 'package:ecomodation/UserLogin/PhoneLogin/PhoneAuthService.dart';
import 'package:ec'
    'omodation/main.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:pinput/pinput.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

bool loggedInWithPhone = false; //set to true since user has been logged in

class OtpUI extends StatefulWidget {
  final String verificationId; //get the verification Id.
  final String phoneNo;

  const OtpUI({Key? key, required this.verificationId, required this.phoneNo})
      : super(key: key);

  @override
  State<OtpUI> createState() => _OtpUIState();
}

class _OtpUIState extends State<OtpUI> {
  late Timer timer;
  int remainingTime = 60; // Initial remaining time in seconds
  bool isResent = false;
  final formKeyOTP = GlobalKey<FormState>(); //key for the OTP
  FirebaseAuth auth = FirebaseAuth.instance;
  final otpTextController =
      TextEditingController(); //Control the text for the OTP

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    otpTextController.dispose();
    timer.cancel();
    super.dispose();
  }

  void startTimer() //Function to start the timer
  {
    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(oneSec, (timer) {
      setState(() {
        if (remainingTime < 1) {
          timer.cancel();
        } else {
          remainingTime--;
        }
      });
    });
  }

  final defaultPinTheme = PinTheme(
    width: 58,
    height: 58,
    textStyle: const TextStyle(
        fontSize: 25, color: Colors.black, fontWeight: FontWeight.w600),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.black),
      borderRadius: BorderRadius.circular(22),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorTheme, //set the background color
        body: _otpForm(context),
      ),
    );
  }

  Widget _otpForm(BuildContext context) {
    final phoneLoginLoading = context.watch<PhoneAuthService>();
    return Form(
        key: formKeyOTP,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_rounded,
                        size: 35, color: Colors.black)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
                child: Text(
              "Enter your OTP",
              style: TextStyle(
                  fontSize: screenWidth / 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'LibreBaskerville'),
            )),
            Padding(
              padding: EdgeInsets.only(top: screenWidth / 2),
              child: Center(child: _pinInputUI(context)),
            ),
            const SizedBox(
              height: 20,
            ),
            Center(
                child: InkWell(
              onTap: () async {
                if (remainingTime < 1) {
                  otpTextController
                      .clear(); //making sure to clear the OTP fields
                  String newOTPVerificationID = await phoneLoginLoading.sendOTP(
                      widget.phoneNo); //send the OTP again to the phone number
                  isResent = await phoneLoginLoading.checkOTP(
                      newOTPVerificationID, widget.phoneNo);
                } else {
                  return;
                }
              },
              child: phoneLoginLoading.isLoading
                  ? const CircularProgressIndicator(
                      strokeWidth: 6,
                      color: Colors.black,
                    )
                  : Text(
                      "Resend OTP?  $remainingTime s",
                      style: const TextStyle(
                        fontSize: 14,
                        decoration: TextDecoration
                            .underline, // Add underline decoration
                      ),
                    ),
            )),
          ],
        ));
  }

  /*------------------------ Widget for building the Pinput UI ------------------------------*/

  Widget _pinInputUI(BuildContext context) {
    final phoneLoginLoading = context.watch<PhoneAuthService>();
    return SizedBox(
      width: screenWidth - 20,
      child: Pinput(
          controller: otpTextController,
          length: 6,
          // Length for the OTP being entered
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
          onCompleted: (value) async {
            try {
              if (formKeyOTP.currentState!.validate()) {
                bool checkOTP = await phoneLoginLoading.checkOTP(
                    widget.verificationId, otpTextController.text);

                if (checkOTP && mounted) {
                  Navigator.pushNamed(context, 'HomeScreen');
                  await storage.write(key: 'LoggedIn', value: "true");
                }
              }
              if (isResent && mounted) {
                Navigator.pushNamed(context, 'HomeScreen');
                await storage.write(key: 'LoggedIn', value: "true");
              } else {
                Fluttertoast.showToast(
                  msg: 'OTP entered is incorrect, try again',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  backgroundColor: Colors.white,
                  textColor: Colors.black,
                );
              }
            } catch (e) {
              Fluttertoast.showToast(
                msg: 'An error occurred, try again',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.CENTER,
                backgroundColor: Colors.white,
                textColor: Colors.black,
              );
            }
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
}
