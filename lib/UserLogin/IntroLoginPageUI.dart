
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

    return  PopScope(
      canPop: false,
      child: Scaffold(

          backgroundColor: Colors.white,

          body: Column(
              children: <Widget>[
            const Padding(padding: EdgeInsets.only(top: 50)),
            Text(
              "Ecomodation ", //Name of the app displayed on top
              textAlign: TextAlign.center, //center the name
              style: TextStyle(   //Some styling for the text
                color: Colors.black,
                fontSize: screenWidth/10,
                fontWeight: FontWeight.bold,
                fontFamily: 'LibreBaskerville',
              ),
            ),

            const SizedBox(height: 20), //Padding after the name

            Container(
              alignment: const Alignment(0, -0.6), //Align the animated text
              child: AnimatedTextKit(  //Using the animated textkit from packages
                animatedTexts: [
                  TyperAnimatedText(
                    'Accomodation made easier for you',  //Text to be displayed
                    textStyle: TextStyle( //style the text
                      fontSize: screenWidth/25, //Adjust the size of the text
                      fontWeight: FontWeight.bold,
                      fontFamily: 'LibreBaskerville',
                    ),
                    speed: const Duration(milliseconds: 80), //How fast the animation runs
                  ),
                ],
                totalRepeatCount: 10,   //Repeat once
                displayFullTextOnTap: true, //Display full text when tapped on it
                stopPauseOnTap: true, //Pause it on tap, set it on true
              ),
            ),
                Padding(
                    padding: const EdgeInsets.only(top: 50),
                    child: Center(child: Image.asset("assets/images/Logo.png", scale: screenWidth/95,))),
            const Spacer(),
            Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: buildAllLoginButtons()), //Calling the build all login butotns
            //fontStyle:
          ]),

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
          Navigator.push(context, MaterialPageRoute(
            builder: (context) => HomeScreenUI(),
          ));
        } else {
          return;
        }
      },
    );
  }

  Widget buildAppleButton() {
    //Using it as a separate widget to make it easy to implement it in condition for PlatformWidget
    //Button for apple signin
    return SignInButton(
      Buttons.Apple,
      onPressed: () {},
    );
  }

  Widget buildLoginPhoneButton() //Button for the login with phone
  {
    return Align(
      alignment: const Alignment(0, 0.9),
      child: ElevatedButton.icon(
        onPressed: () { Navigator.pushNamed(context, "LoginWithPhone");
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
        buildGoogleButton(),

        const SizedBox(height: 20),
        //Button for apple sign in
        buildAppleButton(),

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


}
