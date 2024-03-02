import 'package:ecomodation/PhoneLogin/OTPpage.dart';
import 'package:ecomodation/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'phoneLogin/PhoneSignupUI.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'dart:io';
import 'Auth/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


class _LoginScreenState extends State<LoginScreen> {
  bool login = false; //to check if user logged in or not
  final FirebaseAuth auth = FirebaseAuth.instance; //create instance for firebase sign in


  void handleLoginButtonPress(BuildContext context) //Function to handle LoginButtonPress
  {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const PhoneSignupInfo()),);
  }

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 932); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }


  @override
  Widget build(BuildContext context) {

    double textSizeEcomodation = fontSize(context, 45); //size for Ecomodation (heading)
    double textSizeAnimated = fontSize(context, 20); //size for Animated text on top
    double topPaddingEcom = screenHeight/11.65; //Adjust padding accordingly for top text
    double animatedPadding = topPaddingEcom/2;  //Adjust padding accordingly between top text and animated text
    double getStartedPadding = topPaddingEcom*2; //adjust padding accordingly between the top of the phone and get started button

    return  PopScope(
      canPop: false,
      child: Scaffold(

          backgroundColor: Colors.white,

          body: Column(
              children: <Widget>[
            Padding(padding: EdgeInsets.only(top: topPaddingEcom)),
            Text(
              "Ecomodation ", //Name of the app displayed on top
              textAlign: TextAlign.center, //center the name
              style: TextStyle(   //Some styling for the text
                color: Colors.black,
                fontSize: textSizeEcomodation,
                fontWeight: FontWeight.bold,
                fontFamily: 'LibreBaskerville',
              ),
            ),

            SizedBox(height: animatedPadding), //Padding after the name

            Container(
              alignment: const Alignment(0, -0.6), //Align the animated text
              child: AnimatedTextKit(  //Using the animated textkit from packages
                animatedTexts: [
                  TyperAnimatedText(
                    'Accomodation made easier for you',  //Text to be displayed
                    textStyle: TextStyle( //style the text
                      fontSize: textSizeAnimated, //Adjust the size of the text
                      fontWeight: FontWeight.bold,
                    ),
                    speed: const Duration(milliseconds: 80), //How fast the animation runs
                  ),
                ],
                totalRepeatCount: 10,   //Repeat once
                displayFullTextOnTap: true, //Display full text when tapped on it
                stopPauseOnTap: true, //Pause it on tap, set it on true
              ),
            ),

             SizedBox(height: getStartedPadding),

            buildGetStartedButton(), //Get started Button

            buildAllLoginButtons(), //Calling the build all login butotns
            //fontStyle:
          ]),

      ),
    );

  }




/*----------------- BUTTON IMPLEMENTATIONS -----------------------------------*/

  Widget buildGetStartedButton() {
    var getStartedWidth = screenWidth - 130;
    var getStartedHeight = (screenHeight / 2.19) / 5.31;
    double getStartedTextSize = fontSize(context, 23);

    return ElevatedButton(
      onPressed: () {
        handleLoginButtonPress(context);
      },
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
        elevation: MaterialStateProperty.all(30),
        shadowColor: MaterialStateProperty.all<Color>(Colors.black),
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
      child: Container(
        width: getStartedWidth,
        height: getStartedHeight,
        alignment: Alignment.center,
        child: Text(
          "Get Started",
          style: TextStyle(
            fontSize: getStartedTextSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }


  Widget buildGoogleButton() {

    //Using it as a separate widget to make the main build widget cleaner
    //Button for google sign in
    return SignInButton(
      Buttons.Google,
      onPressed: () {
        Authentication().signInWithGoogle().then((userCred) {
          //If Login is successful, then
          if (userCred != null) {
            Navigator.pushNamed(context, 'HomeScreen' ); //Navigate to the home screen.
          }
        });
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
          fixedSize: MaterialStateProperty.all(const Size(220, 25)),
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

    double aftergetStartedPadding = screenHeight / 4; //adjust padding accordingly after the get started button
    double paddingotherbuttons = screenHeight / 37.28; //adjust the padding between other buttons accordingly to the screenHeight;

    if (Platform.isIOS) //If the platform is IOS, return all three buttons
    {
      return Expanded(
        child: Column(children: [
          SizedBox(height: aftergetStartedPadding),
          //Button for google sign in
          buildGoogleButton(),

          SizedBox(height: paddingotherbuttons),
          //Button for apple sign in
          buildAppleButton(),

          SizedBox(height: paddingotherbuttons),
          buildLoginPhoneButton(),
          //Button for phone login
          // fontStyle:]
        ]),
      );
    }
    else if (Platform.isAndroid) //If platform is Android, return all buttons except the apple sign in
    {
      return Expanded(
        child: Column(children: [
          SizedBox(height: aftergetStartedPadding),
          //Button for google sign in
          buildGoogleButton(),
          SizedBox(height: paddingotherbuttons),
          buildLoginPhoneButton(),
        ]),
      );
    }
    return Container(); //Returns an empty container if the platform is neither IOS or Android.
  }
}
