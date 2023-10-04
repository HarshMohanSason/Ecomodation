import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'AddListing.dart';

class AppSettings extends StatefulWidget {
  const AppSettings({Key? key}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}

class _AppSettingsState extends State<AppSettings> {

  Authentication instance = Authentication();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(top: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

             Align(
             alignment: Alignment.topLeft,
             child: IconButton (
                 onPressed: () {
                   Navigator.pushNamed(context, 'HomeScreen');
                 },
                 icon:  Icon(Icons.home, size: screenWidth/12, color: Colors.black)
               ),
             ),
                 const SizedBox(height: 400),
                 logoutButton()
          ],
        ),
      )
    );
  }
  Widget logoutButton()
  {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        style: ButtonStyle(
          fixedSize: MaterialStateProperty.all(const Size(160, 40)),
          backgroundColor: const MaterialStatePropertyAll(
              colorTheme), //set the color for the continue button
        ),
        onPressed: () async {
        await instance.signOut();
        //oogleLoginDocID.clear();
        try{
          Navigator.pushNamed(context, 'LoginPage');
       }
            catch(e)
          {
            Text('Could not sign out ${e}');
          }
        },
        child: Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 18 * (screenHeight/ 932),
            color: const Color(0xFFFFFFFF),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
