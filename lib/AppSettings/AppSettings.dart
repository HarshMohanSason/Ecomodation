
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/OTPpage.dart';
import 'package:ecomodation/main.dart';
import 'currentUserInfo.dart';
import 'package:flutter/material.dart';

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
        padding:  EdgeInsets.only(top: screenHeight/14),
        child: SingleChildScrollView(
          
          child: SizedBox(
            height: screenHeight,
            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,

              children: [

                 Row(
                   children: [
                     Align(
                     alignment: Alignment.topLeft,
                     child: IconButton (
                         onPressed: () {
                           Navigator.pushNamed(context, 'HomeScreen');
                         },
                         icon:  Icon(Icons.arrow_back_sharp, size: screenWidth/12, color: Colors.black)
                       ),
                     ),
                     const Spacer(),
                     Align(
                       alignment: Alignment.topRight,
                       child: IconButton (
                           onPressed: () {
                             //Navigator.pushNamed(context, 'HomeScreen');
                           },
                           icon:  Icon(Icons.notifications, size: screenWidth/12, color: Colors.black)
                       ),
                     ),
                   ],
                 ),
                 SizedBox(height: screenHeight/15),
                displayProfilePicture(),
                    const SizedBox(height: 20),

                 displaySettingOptions(),
              ],
            ),
          ),
        ),
      )
    );
  }

 Widget displayProfilePicture() {

      return Center(
        child: FutureBuilder(
          future: getCurrentUserInfo(),
              builder: (context, snapshot)
          {
            if(snapshot.connectionState == ConnectionState.waiting)
            {
              return const CircularProgressIndicator();
            }
            if(!snapshot.hasData || snapshot.hasError)
              {
                return  Icon(
                  Icons.person, // Display a default icon when imageUrl is null
                  color: Colors.white,
                  size: screenWidth/7.5,
                );
              }
            else {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  ClipOval(
                    child: Container(
                    color: Colors.lightBlueAccent,
                     width: screenWidth/2.4,
                     height: screenHeight/5.17,
                      child: Image.network(
                        snapshot.data!.profileImage != null ? snapshot.data!.profileImage! : "", errorBuilder: (BuildContext context, Object exception, StackTrace? stacktrace)
                        {
                          return  Icon(
                            Icons.person, // Display a default icon when imageUrl is null
                            color: Colors.white,
                            size: screenWidth/7.5,
                          );
                        } , fit: BoxFit.fitWidth,
                      ),
                    ),
                  ),
                const SizedBox(height: 15),
                  Text(snapshot.data!.userName, style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth/20,
                  ))
                ],
              );

            }
          }),
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
          if(mounted) {
            Navigator.pushNamed(context, 'LoginPage');
          }
       }
            catch(e)
          {
            Text('Could not sign out $e');
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


  Widget displaySettingOptions(){

    return Expanded(

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children:  [

           const Divider(color: Colors.black, thickness: 4,),
          const  SizedBox(height: 20),

          ListTile(
          leading: Icon(Icons.location_on, size: 40),
            tileColor: Colors.white,
            title: Text("Location Services", style: TextStyle(
              fontSize: 15,
            )),
            dense: true,

          ),
          SizedBox(height: 20),

           ListTile(
              leading: Icon(Icons.home, size: 40),
              tileColor: Colors.white,
              title: Text("Your Listings", style: TextStyle(
                fontSize: 15,
              )),
              dense: true
            ),
          SizedBox(height: 20),
           ListTile(
              leading: Icon(Icons.favorite, size: 40),
              tileColor: Colors.white,
              title: Text("Favourites", style: TextStyle(
                fontSize: 15,
              )),
              dense: true
          ),
        const SizedBox(height: 20),
          const  ListTile(
              leading: Icon(Icons.info, size: 40),
              tileColor: Colors.white,
              title: Text("About", style: TextStyle(
                fontSize: 15,
              )),
              dense: true
          ),
          SizedBox(height: 20),
          ListTile(
            onTap: () async{
             await instance.signOut();

             if(loggedInWithGoogle == false && mounted)
               {
                 Navigator.pushNamed(context, 'AppIntroUI');
               }
             else if(loggedInWithPhone == false && mounted)
               {
                 Navigator.pushNamed(context, 'AppIntroUI');
               }
            } ,

              leading: Icon(Icons.logout, size: 40),
              tileColor: Colors.white,
              title: Text("Sign out", style: TextStyle(
                fontSize: 15,
              )),
              dense: true
          ),


        ],

      ),
    );
  }












  Future<CurrentUserInfo?> getCurrentUserInfo() async{ //function to get the current userInfo

    try{
      if(loggedInWithGoogle == true) {
        var document = await FirebaseFirestore.instance.collection('userInfo')
            .doc(googleLoginDocID).get();
        var info = document.data() as Map<String, dynamic>;
      return CurrentUserInfo(profileImage: info['photoURL'] , userName: info['username'] , contact: info['email']);
      }
      else if(loggedInWithPhone == true)
      {
        var document = await FirebaseFirestore.instance.collection('userInfo')
            .doc(phoneLoginDocID).get();
        var info = document.data() ;
       return CurrentUserInfo(profileImage: info!['photoURL'] , userName: info['username'] , contact: info['phonenumber']);
      }
    }
    catch(e)
    {
      rethrow;
    }
return null;
  }

}
