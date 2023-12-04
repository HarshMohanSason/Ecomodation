import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';

import 'Modelload.dart';

class AppSettings extends StatefulWidget {

   final String? googleImageUrl;
   const AppSettings({Key? key, this.googleImageUrl}) : super(key: key);

  @override
  State<AppSettings> createState() => _AppSettingsState();
}


class _AppSettingsState extends State<AppSettings> {

  Authentication instance = Authentication();
  @override

  void initState() {
   // print(widget.googleImageUrl);
    super.initState();

  }
  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: Colors.white,

      body: Padding(
        padding: const EdgeInsets.only(top: 80),
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
            const SizedBox(height: 80),
            displayProfilePicture(),
                 const SizedBox(height: 100),
                 logoutButton()
          ],
        ),
      )
    );
  }

  displayProfilePicture() {

    try {

      String? imageURL = widget.googleImageUrl;

      return Center(
        child: Container(
          color: Colors.grey,
          width: 200,
          height: 200,
          child: ClipOval(
            child: imageURL != null
                ? Image.network(
              imageURL,
              fit: BoxFit.fitWidth,
            )
                : Icon(
              Icons.person, // Display a default icon when imageUrl is null
              size: 100,
            ),
          ),
        ),
      );
    }
    catch(e)
    {
    //  print(e);
    }
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
          if(mounted) {
            Navigator.pushNamed(context, 'LoginPage');
          }
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
