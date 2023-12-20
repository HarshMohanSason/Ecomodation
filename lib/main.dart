import 'package:ecomodation/AddListingsUI/AddDescription.dart';
import 'package:ecomodation/AppSettings/AppSettings.dart';
import 'package:ecomodation/AddListingsUI/ListingPrice.dart';
import 'package:ecomodation/Listings/AskButtonState.dart';
import 'package:ecomodation/Listings/DisplayListings.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/NoMessageWidget.dart';
import 'package:ecomodation/Messaging/homeScreenMessageUI.dart';
import 'package:ecomodation/PhoneSignupUI.dart';
import 'package:ecomodation/homeScreenUI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './loginpage.dart';
import 'AddListingsUI/AddListing.dart';
import 'Auth/auth_checkifloggedin.dart';
import 'firebase_options.dart';
import 'AddListingsUI/AddListing_StateManage.dart';

// Declaring them as global as they are used in almost all the files to resize different widgets according to different devices.

double screenWidth = 0.0; //get the height of the screen in separate Global variable.
double screenHeight = 0.0; //get the width of the screen in separate Global variable
const Color colorTheme = Colors.green; //Main Color theme of the app

void main() async {

  WidgetsFlutterBinding.ensureInitialized(); //Make sure all the widgets are intialized
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); //Initialize firebase


  Size screenSize = WidgetsBinding.instance.window.physicalSize; //get the device pixel size
  screenWidth = screenSize.width / WidgetsBinding.instance.window.devicePixelRatio; //get the logical pixels in terms of the width
  screenHeight = screenSize.height / WidgetsBinding.instance.window.devicePixelRatio;  //get the logical pixels in terms of height


  runApp(
      MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AddListingState()),
        ChangeNotifierProvider(create: (context) => DetailedListingStateManage()),
      ],
      child: const Ecomodation())
  );

}



class Ecomodation extends StatelessWidget {

  const Ecomodation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return
      MaterialApp(

          home: const CheckIfLoggedIn(), //Check if the user is already logged in or not
          initialRoute: 'loginpage', //define the inital route as login page
          routes:
          {
            'LoginPage': (context) => const LoginScreen(),
            'PhoneSignupPage': (context) => const PhoneSignupInfo(),
            'HomeScreen': (context) =>  HomeScreenUI(),
            'AppIntroUI': (context) => const LoginScreen(),
            'AddImagePage': (context) => const AddListing(),
            'AddDescriptionPage': (context) => const AddDescription(),
            'AddPricePage': (context) => const ListingPrice(),
            'LoginWithPhone': (context) => const LoginWithPhone(),
            'NoMessageWidget': (context) => const NoMessageWidget(),
            'AppSettings':(context)=> const AppSettings(),
            'DisplayListings': (context) => const DisplayListings(),
            'HomeScreenMessagingUI': (context) => HomeScreenMessagingUI()
          }
      );
  }

}