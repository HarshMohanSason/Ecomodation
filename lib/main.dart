
import 'package:ecomodation/AddListingsUI/AddDescription.dart';
import 'package:ecomodation/AppSettings/AboutUs.dart';
import 'package:ecomodation/AppSettings/AppSettings.dart';
import 'package:ecomodation/AddListingsUI/ListingPrice.dart';
import 'InternetChecker.dart';
import 'UserLogin/GoogleLogin/GoogleAuthService.dart';
import 'package:ecomodation/Listings/DisplayListings.dart';
import 'package:provider/provider.dart';
import 'AddListingsUI/ListingProgressIndicatorBar.dart';
import 'UserLogin/GoogleLogin/GoogleAuthService.dart';
import 'UserLogin/IntroLoginPageUI.dart';
import 'UserLogin/PhoneLogin/PhoneAuthService.dart';
import 'UserLogin/PhoneLogin/LoginWithPhoneUI.dart';
import 'package:ecomodation/Messaging/NoMessageWidget.dart';
import 'package:ecomodation/Messaging/homeScreenMessageUI.dart';
import 'UserLogin/PhoneLogin/PhoneSignupUI.dart';
import 'package:ecomodation/homeScreenUI.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'UserLogin/checkIfLoggedIN.dart';
import 'firebase_options.dart';


// Some Global variable Declarations

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
    return MultiProvider(

      providers: [
        ChangeNotifierProvider(create: ((context)=> GoogleAuthentication())),
        ChangeNotifierProvider(create: ((context) => InternetProvider())),
      ],
      child: MaterialApp(
              home: const CheckIfLoggedIn(),
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
          ),
    );
  }
}