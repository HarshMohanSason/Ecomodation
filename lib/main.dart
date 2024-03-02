
import 'package:ecomodation/AddListingsUI/AddDescription.dart';
import 'package:ecomodation/AppSettings/AboutUs.dart';
import 'package:ecomodation/AppSettings/AppSettings.dart';
import 'package:ecomodation/AddListingsUI/ListingPrice.dart';
import 'package:ecomodation/Listings/DisplayListings.dart';
import 'AddListingsUI/ListingProgressIndicatorBar.dart';
import 'Auth/checkIfLoggedIN.dart';
import 'IntorLoginPage.dart';
import 'phoneLogin/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/NoMessageWidget.dart';
import 'package:ecomodation/Messaging/homeScreenMessageUI.dart';
import 'phoneLogin/PhoneSignupUI.dart';
import 'package:ecomodation/homeScreenUI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'firebase_options.dart';


// Declaring them as global as they are used in almost all the files to resize different widgets according to different devices.

double screenWidth = 0.0; //get the height of the screen in separate Global variable.
double screenHeight = 0.0; //get the width of the screen in separate Global variable
const Color colorTheme = Colors.white; //Main Color theme of the app

const storage = FlutterSecureStorage(); //create a secure storage

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); //Make sure all the widgets are intialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); //Initialize firebase

  Size screenSize = WidgetsBinding.instance.window.physicalSize; //get the device pixel size
  screenWidth = screenSize.width / WidgetsBinding.instance.window.devicePixelRatio; //get the logical pixels in terms of the width
  screenHeight = screenSize.height / WidgetsBinding.instance.window.devicePixelRatio;  //get the logical pixels in terms of height

  runApp( const Ecomodation());
}

class Ecomodation extends StatelessWidget {

  const Ecomodation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
            home: CheckIfLoggedIn(),
            routes:
            {
              'LoginPage': (context) => const LoginScreen(),
              'PhoneSignupPage': (context) => const PhoneSignupInfo(),
              'HomeScreen': (context) =>  HomeScreenUI(),
              'AppIntroUI': (context) => const LoginScreen(),
              'ListingProgressBar': (context) => const ListingProgressBar(),
              'AddDescriptionPage': (context) =>  AddDescription(),
              'AddPricePage': (context) => const ListingPrice(),
              'LoginWithPhone': (context) => const LoginWithPhone(),
              'NoMessageWidget': (context) => const NoMessageWidget(),
              'AppSettings':(context)=> const AppSettings(),
              'DisplayListings': (context) => const DisplayListings(),
              'HomeScreenMessagingUI': (context) => const HomeScreenMessagingUI(),
              'AboutUsScreen': (context) => const AboutUsPage(),
            }
        );
  }
}