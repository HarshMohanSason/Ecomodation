
import 'package:ecomodation/UserLogin/PhoneLogin/LoginWithPhoneUI.dart';
import 'package:ecomodation/UserLogin/PhoneLogin/OTPpageUI.dart';
import 'package:ecomodation/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../InternetChecker.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'dart:io';
import '../homeScreenUI.dart';
import 'AppleLogin/AppleLoginService.dart';
import 'GoogleLogin/GoogleAuthService.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  bool login = false; //to check if user logged in or not
  final FirebaseAuth auth = FirebaseAuth.instance; //create instance for firebase sign in


  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 932); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(height: screenHeight * 0.05),
          Text(
            "Ecomodation",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: screenWidth / 10,
              fontWeight: FontWeight.bold,
              fontFamily: 'LibreBaskerville',
            ),
          ),
          SizedBox(height: screenHeight * 0.02),
          Container(
            alignment: Alignment.center,
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  'Accommodation made easier for you',
                  textStyle: TextStyle(
                    fontSize: screenWidth / 25,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'LibreBaskerville',
                  ),
                  speed: const Duration(milliseconds: 80),
                ),
              ],
              totalRepeatCount: 10,
              displayFullTextOnTap: true,
              stopPauseOnTap: true,
            ),
          ),
          SizedBox(height: screenHeight * 0.05),
          Center(
            child: Image.asset(
              "assets/images/Logo.png",
              scale: screenWidth / 95,
            ),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 20),
            child: buildAllLoginButtons(),
          ),
        ],
      ),
    );
  }





/*----------------- LOGIN BUTTONS IMPLEMENTATIONS -----------------------------------*/



  Widget buildGoogleButton() {

    final sp = context.watch<GoogleAuthentication>();

    return sp.isLoading ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 6,) : SignInButton(
      Buttons.Google,
      onPressed: () async {
        try {
          await handleGoogleLogin();
        }
        catch(e)
        {
         throw e.toString();
        }
        // Check if the user is signed in with Google and then navigate to HomeScreen
        if (mounted && context.read<GoogleAuthentication>().isSignedIn == true) {
          const CircularProgressIndicator();
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreenUI(),));
        } else {
          return;
        }
      },
    );
  }

  Widget buildAppleButton() {
    final appleLoginLoading = context.watch<AppleLoginService>();
    //Using it as a separate widget to make it easy to implement it in condition for PlatformWidget
    //Button for apple signin
    return appleLoginLoading.isLoading
        ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 6,) :SignInButton(
      Buttons.Apple,
      onPressed: () async {
        try {
          await handleAppleLogin(context);
        } catch(e) {

        }
        if (appleLoginLoading.isSignedIn == true && mounted) {
          Navigator.push(context, MaterialPageRoute(
            builder: (context) =>  HomeScreenUI(),
          ));
        }
      },
    );
  }

  Widget buildLoginPhoneButton() //Button for the login with phone
  {
    return Align(
      alignment: const Alignment(0, 0.9),
      child: ElevatedButton.icon(
        onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context)=> LoginWithPhone()));
        },//Navigate to the loginWithPhone
        style: ButtonStyle(
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5),
              )),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
          fixedSize: MaterialStateProperty.all(const Size(220, 20)),
        ),
        icon: const Padding(
          padding: EdgeInsets.only(left: 0, right: 8),
          child: Icon(
            Icons.phone,
            color: Colors.white,
            size: 18,
          ),
        ),
        label: const Padding(
          padding: EdgeInsets.only(right: 18.0),
          child: Text("Login with Phone  ",
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              )),
        ),
      ),
    );
  }

  Widget buildAllLoginButtons() {

    if (Platform.isIOS) //If the platform is IOS, return all three buttons
    {
      return Column(children: [

        buildAppleButton(),


        const SizedBox(height: 20),
        //Button for apple sign in
        buildGoogleButton(),

        const SizedBox(height: 20),
        buildLoginPhoneButton(),
        //Button for phone login
        // fontStyle:]
      ]);
    }
    else if (Platform.isAndroid) //If platform is Android, return all buttons except the apple sign in
    {
      return Expanded(
        child: Column(children: [
          const SizedBox(height: 20),
          //Button for google sign in
          buildGoogleButton(),
          const SizedBox(height: 20),
          buildLoginPhoneButton(),
        ]),
      );
    }
    return Container(); //Returns an empty container if the platform is neither IOS or Android.
  }



  //Function to handle login via Google
  Future<void> handleGoogleLogin() async {

    final sp = context.read<GoogleAuthentication>();
    final ip = context.read<InternetProvider>();

    await ip.checkInternetConnection(); // Check internet connection

    if (!ip.hasInternet) {
      // Display a toast message if there is no internet connection
      Fluttertoast.showToast(
        msg: 'Check your Internet Connection',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    }
    else {
      try {
        // Attempt sign in with Google
        await sp.signInWithGoogle();
        await storage.write(key: 'LoggedIn', value: "true");
      } catch (e) {
        rethrow;
      }
    }
  }

  Future<void> handleAppleLogin(BuildContext context) async
  {
    final ip = context.read<InternetProvider>();
    final ap = context.read<AppleLoginService>();
    await ip.checkInternetConnection(); // Check internet connection

    if (!ip.hasInternet) {
      // Display a toast message if there is no internet connection
      Fluttertoast.showToast(
        msg: 'Check your Internet Connection',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.white,
        textColor: Colors.black,
      );
    }
    else {
      try {
        // Attempt sign in with Google
        await ap.appleLogin();
        await storage.write(key: 'LoggedIn', value: "true");
      } catch (e) {
       print(e);
      }
    }
  }



}
