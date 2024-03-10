
import 'package:ecomodation/main.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget{

  const AboutUsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(
            title: Text('About us',
              style: TextStyle(

                fontSize: screenWidth/13,
              ),)
        ),
        body: SingleChildScrollView(
          child: Padding(
              padding: const EdgeInsets.only(top: 15, left: 5),
              child: Text(
                '''Ecomodation is an apartment renting app with a goal to make renting apartments easier for you. Our Goal was to simply make apartment finding free of cost with an extremely user friendly UI. Most apps confuse the user on what to do where to go because there is just too much going on in it. We made it super basic and sleek. Simply enter your location and just surf through apartments to find them. Once you find the one you like, simply send them a message and wait for them to respond.\n\n You do not need to pay any sort of fees, down payment, membership or any other thing. Just enter the location and find apartments to rent free of cost.\n\n Note that we are still new and trying to get as much users as we can on the app. If you have any questions or find any bugs, please feel free to reach out to us so we can address the issue.\n\n Happy Apartment Hunting!
  ''',
                style: TextStyle(
                  fontSize: screenWidth/22,
                ),)
          ),
        ));
  }

}

