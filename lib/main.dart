import 'package:ecomodation/AddDescription.dart';
import 'package:ecomodation/ListingPrice.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/PhoneSignupUI.dart';
import 'package:ecomodation/homepage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import './loginpage.dart';
import 'AddListing.dart';
import 'firebase_options.dart';
import 'AddListing_StateManage.dart';

// Declaring them as global as they are used in almost all the files to resize different widgets according to different devices.

double screenWidth = 0.0; //get the height of the screen in separate variable.
double screenHeight = 0.0; //get the width of the screen in separate variable
const Color colorTheme = Color(0xFF0BC25F); //Main Color theme of the app

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
      ],
      child: const Ecomodation())
  );

}



class Ecomodation extends StatelessWidget {
  const Ecomodation({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
   /* return  FutureBuilder<User>(
      future:  Future.value(FirebaseAuth.instance.currentUser),
      builder: (BuildContext context, AsyncSnapshot<User> snapshot) {


        if(snapshot.hasData)
          {
            User? user = snapshot.data;

            return  MaterialApp(
              home: MainScreen(),
                routes:
                {
                'LoginPage': (context) => const LoginScreen(),
                'PhoneSignupPage': (context) => const PhoneSignupInfo(),
                'HomeScreen': (context) => const MainScreen(),
                'AppIntroUI': (context) => const LoginScreen(),
                'AddImagePage':(context) => const AddListing(),
                'AddDescriptionPage': (context) => const AddDescription(),
                'AddPricePage': (context) => const ListingPrice(),
                }
            );
          }
      else {

    */
          return
        MaterialApp(

            home: const LoginScreen(),
            initialRoute: 'loginpage', //define the inital route as login page
            routes:
            {
              'LoginPage': (context) => const LoginScreen(),
              'PhoneSignupPage': (context) => const PhoneSignupInfo(),
              'HomeScreen': (context) => const MainScreen(),
              'AppIntroUI': (context) => const LoginScreen(),
              'AddImagePage':(context) => const AddListing(),
              'AddDescriptionPage': (context) => const AddDescription(),
              'AddPricePage': (context) => const ListingPrice(),
              'LoginWithPhone': (context)=> LoginWithPhone(),
            }
        );
        }
   //   },

   // );
 // }

}
