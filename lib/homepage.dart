import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/Listings/DisplayListings.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/Messaging/MessageWidget.dart';
import 'package:ecomodation/OTPpage.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:location/location.dart' as Location;
import 'CustomIcons/my_flutter_app_icons.dart' as custom_icons;
import  'package:geocoding/geocoding.dart';
import  'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MainScreen extends StatefulWidget {

  double _currentSliderValue = 5;
  double  latitude = 0;
  double  longitude = 0;

  double get enteredDistanceRange => _currentSliderValue;
  double get getLatitude => latitude;
  double get getLongitude => longitude;

  set distanceRange(double range) =>  _currentSliderValue = range;
  set setLatitude(double latitude) => this.latitude = latitude;
  set setLongitude(double longitude) => this.longitude = longitude;

 // final String imagePath;
   MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  MainScreen _mainScreen = MainScreen();

  bool _serviceEnabled = false;
  Location.Location location = Location.Location();
  late Location.LocationData locationData;
  late Location.PermissionStatus permissionStatus;

  TextEditingController enterZipCode = TextEditingController();


  final String currentUserID = FirebaseAuth.instance.currentUser!.uid;
  final writeUserInfo =  FirebaseFirestore.instance.collection('userInfo');

  Future<LocationPermission> getPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if(permission == LocationPermission.denied) {
        return Future.error('Locatoin permission are denied');
      }
    }
    return permission;
  }

  Future<void> enableUserLocation() async {

    await getPermission();  //get the permissions to enable the UserLocation

    try {
      _serviceEnabled = await location.serviceEnabled();

      if (_serviceEnabled == true) {
        _serviceEnabled = await location.requestService();
        permissionStatus = await location.hasPermission();
      }
      if (permissionStatus == Location.PermissionStatus.denied) {
        permissionStatus = await location.requestPermission(
        );
      }

      locationData = await location.getLocation();

      _mainScreen.setLatitude = locationData.latitude!;
      _mainScreen.setLongitude = locationData.longitude!;

      List<Placemark> placemarks = await placemarkFromCoordinates(
        _mainScreen.getLatitude, _mainScreen.getLongitude,);

      Placemark zipcode = placemarks[0];

      setState(() {
        enterZipCode.text = zipcode.postalCode!;
      });
    }
    catch(e)
    {
      // print(e);
    }
  }

  Future<void> _uploadLocation() async {

    try {
      if (loggedInWithPhone == true) {
        await writeUserInfo.doc(phoneLoginDocID).update({
          'Latitude': _mainScreen.getLatitude,
          'Longitude': _mainScreen.getLongitude,
          'Range':  _mainScreen.enteredDistanceRange,
        });
      }
      else if (loggedInWithGoogle == true) {
        await writeUserInfo.doc(googleLoginDocID).update({
          'Latitude': _mainScreen.getLatitude,
          'Longitude': _mainScreen.getLongitude,
          'Range':  _mainScreen.enteredDistanceRange,
        });
      }
      // Handle success, if needed
    } catch (e) {
      // catch errors here.
     // print('Error updating location: $e');
    }

}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: colorTheme,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
           const Padding(padding: EdgeInsets.only(top:50,)),
            _locationWidget(),
              Align(
               alignment: Alignment.topCenter,
                 child: Text('Listings near you', style: TextStyle(
                   fontSize: screenWidth/17,
                   fontWeight: FontWeight.bold,
                 ),)),
             SizedBox(
              height: screenHeight-220,
              child: DisplayListings(),
            ),
            Expanded(
              child: Padding(
                  padding: EdgeInsets.only(bottom: 25),
                      child: _bottomIcons(context)),
            ),
          ],
        )

      ),
    );
  }

  Widget _bottomIcons(BuildContext context) {

    var sizeofIcons = screenWidth/13; //Adjust size of Icons to screenWidth of each screen.

    return Row(
      //Return the icons in a row

      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children:  <Widget>[
        Align(
          //Align the cont
          alignment: const Alignment(0, 0.9),
          child: IconButton(
            onPressed: () => null,
            icon: Icon(Icons.home, color: Colors.black, size: sizeofIcons),
          ),
        ),
       const Spacer(),
        Align(
          alignment: const Alignment(0, 0.90),
          child: IconButton(

            onPressed: ()  {

              Navigator.pushNamed(context, 'AddImagePage');

              },
            icon:
                Icon(Icons.add_a_photo, color: Colors.black, size: sizeofIcons),
          ),
        ),
        const Spacer(),
        Align(
          alignment: const Alignment(0, 0.91),
          child: IconButton(
            onPressed: () => null, // Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDisplay(receiverID: ''))),
            icon: Icon(Icons.messenger_rounded, color: Colors.black, size: sizeofIcons),
          ),
        ),
      const  Spacer(),
        Align(
          alignment: const Alignment(0, 0.9),
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, 'AppSettings'),
            icon: Icon(Icons.settings, color: Colors.black, size: sizeofIcons),
          ),
        ),
      ],
    );
  }


  //Widget searchbar to place at the top.
  Widget _locationWidget(){

    return  IconButton(

        onPressed: ()  {
        // await enableUserLocation();
         _editLocation();
        },
        icon: const Icon(Icons.location_on_outlined, size: 40,color: Colors.black,));
  }


  /*Widget to the edit the location which the user will enter */
  Future _editLocation() {

    return showDialog(context: context, builder: (BuildContext context)
    {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            content: Container(
              color: Colors.white,
              height: screenWidth/1.3,
              width: screenWidth/2,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async {
                      await enableUserLocation();
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                      backgroundColor: MaterialStateProperty.all<Color>(colorTheme),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      fixedSize: MaterialStateProperty.all(const Size(220, 35)),
                    ),
                    icon:  Padding(
                      padding: const EdgeInsets.only(left: 0, right: 8),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: screenWidth/17,
                      ),
                    ),
                    label:  Padding(
                      padding: const EdgeInsets.only(right: 18.0),
                      child: Text("Get my location ",
                          style: TextStyle(
                            fontSize: screenWidth/28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          )),
                    ),
                  ),
                  SizedBox(height: screenHeight/55,),

                   Text('Or',
                  style: TextStyle(
                    fontSize: screenWidth/27
                  ),),
                  SizedBox(height: screenHeight/50),

                  SizedBox(
                    width: screenWidth/3,
                    child: TextField(
                      keyboardType: TextInputType.number,
                      controller: enterZipCode,
                      inputFormatters: [ FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6),],
                      maxLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Enter Zip code',
                        hintStyle:  TextStyle(
                            fontSize: screenWidth/28
                        ),
                        isDense:  true,
                        // contentPadding: const EdgeInsets.all(100),
                        border: OutlineInputBorder(
                          //    borderSide: const BorderSide(width: 10.0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),

                  ),

                  SizedBox(height: screenHeight/50),

                  Align(

                      alignment: const Alignment(-0.8,0),
                      child: Text('Distance (km)',
                          style: TextStyle(
                              fontSize: screenWidth/25,
                          ))),
                  Slider(
                      value: _mainScreen.enteredDistanceRange,
                      activeColor: colorTheme,
                      max:30,
                      min: 5,
                      divisions: 5,
                      label:  _mainScreen.enteredDistanceRange.round().toString(),
                      onChanged: (double value)
                      {
                        setState(() {
                          _mainScreen.distanceRange = value;
                        });
                      }

                  ),

                  Expanded(
                    child: IconButton(
                        onPressed: () async {
                           await _uploadLocation();
                           Navigator.pop(context);
                        },
                        icon:  Icon(custom_icons.MyFlutterApp.ok_circled, size: screenWidth/12,color: Colors.black,)),
                  ),
                ],
              ),
            ),
          );
        },

      );
    });
  }



}
