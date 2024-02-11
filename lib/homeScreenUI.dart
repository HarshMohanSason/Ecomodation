
import 'package:ecomodation/AddListingsUI/ListingProgressIndicatorBar.dart';
import 'package:ecomodation/Listings/DisplayListings.dart';
import 'package:ecomodation/Location_Handler/LocationService.dart';
import 'package:ecomodation/Messaging/homeScreenMessageUI.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'AppSettings/AppSettings.dart';
import 'Auth/getUserIDandFlag.dart';
import 'CustomIcons/my_flutter_app_icons.dart' as custom_icons;

class HomeScreenUI extends StatefulWidget {

  double _currentSliderValue = 5;
  double get enteredDistanceRange => _currentSliderValue;
  set distanceRange(double range) =>  _currentSliderValue = range;

   HomeScreenUI({Key? key}) : super(key: key);

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}


class _HomeScreenUIState extends State<HomeScreenUI> {


  final HomeScreenUI _mainScreen = HomeScreenUI();
  int index = 0;
  final LocationService _locationService = LocationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController enterZipCode = TextEditingController();
  GetUserIDAndFlag checkIfRestarted = GetUserIDAndFlag();
  List<Widget> iconWidgets = [  HomeScreenUI() , ListingProgressBar(), HomeScreenMessagingUI(), AppSettings(),];

  @override
  void initState()
  {
    super.initState();

    checkIfRestarted.getCurrentDocID();
    _locationService.getPermission();
  }

  @override
  void dispose()
  {
    super.dispose();
    checkIfRestarted.dispose();
    enterZipCode.dispose();
  }


//function to get the currentUserLocation Whenever the "Get my Location" button is tapped

  @override
  Widget build(BuildContext context) {
    //index = null;
    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colorTheme,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            if (index == 0) ...[
              const Padding(padding: EdgeInsets.only(top: 50)),
              _locationWidget(),
              Align(
                alignment: Alignment.topCenter,
                child: Text(
                  'Listings near you',
                  style: TextStyle(
                    fontSize: screenWidth / 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Expanded(
                child: DisplayListings(),
              ),
            ],
            if (index != 0 && index != 1)  ...[
              Expanded(child: iconWidgets[index]),
            ],
            _bottomIconsBar(context),  ],
        )

      ),
    );
  }


  Widget _bottomIconsBar(BuildContext context) {

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: index,
      selectedFontSize: 11,
      selectedIconTheme: const IconThemeData(color: Colors.black),
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
        onTap: (x)
        {
          setState(() {
            index = x;
            if(index == 1)
              {
                Navigator.push(context, MaterialPageRoute(builder: (context) => iconWidgets[index]));
              }
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              label: 'Home',
              icon: Icon(
              Icons.home,size: 25
          )),

          BottomNavigationBarItem(
              label: 'Add Listing',
              icon: Icon(Icons.add_a_photo, size: 25
          )),

          BottomNavigationBarItem(
              label: 'Inbox',
              icon: Icon(Icons.message_rounded, size: 25
              )),

          BottomNavigationBarItem(
              label: 'Settings',
              icon: Icon(Icons.settings,size: 25
              )),
        ]
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
  Future _editLocation() async {

    bool getMyLocationPressed = false;

    return showDialog(context: context, builder: (BuildContext context)
    {
      return StatefulBuilder(
        builder: (BuildContext context, void Function(void Function()) setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            content: SizedBox(
              height: screenHeight/3,
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () async { //Whenever get my location is pressed, get the current user location using the API
                      var zipCode = await _locationService.getUserCurrentLocation();
                      setState(() {
                        enterZipCode.text = zipCode!; //fill the zipcode text box with the current  zip code
                        getMyLocationPressed = true;
                      });
                    },
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all<OutlinedBorder?>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(40))),
                      backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
                      foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
                      fixedSize: MaterialStateProperty.all(const Size(220, 35)),
                    ),
                    icon:  const Padding(
                      padding:  EdgeInsets.only(left: 0, right: 8),
                      child: Icon(
                        Icons.location_on_outlined,
                        size: 23,
                      ),
                    ),
                    label: const  Padding(
                      padding:  EdgeInsets.only(right: 18.0),
                      child: Text("Get my location ",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    ),
                  ),

                   Padding(
                     padding: const EdgeInsets.only(top: 10),
                     child: Text('Or',
                                       style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth/27
                                       ),),
                   ),

                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: SizedBox(
                      width: screenWidth/3,
                      child: Form(
                        key: _formKey,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          controller: enterZipCode,
                          inputFormatters: [ FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(6),], //make sure the box only takes digits and zipcode of max 6 digits
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter text';
                            }
                            if (value.length < 5) {
                              return 'Invalid zipCode';
                            }
                            return null; // Return null if the validation is successful
                          },
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 15, left: 15),
                    child: Align(
                        alignment: Alignment.topLeft,
                        child: Text('Distance (km)',
                            style: TextStyle(
                               fontWeight: FontWeight.bold,
                                fontSize: screenWidth/25,
                            ))),
                  ),
                  Slider(
                      value: _mainScreen.enteredDistanceRange,
                      activeColor: Colors.black,
                      max:30,
                      min: 5,
                      divisions: 5,
                      label:  _mainScreen.enteredDistanceRange.round().toString(),
                      onChanged: (double value)
                      {
                        setState(() {
                          _mainScreen.distanceRange = value;
                          _locationService.saveDistanceRange(value.toInt());
                        });
                      }

                  ),

                  Expanded(
                    child: IconButton(
                        onPressed: () async {
                          if(mounted && getMyLocationPressed == true && _formKey.currentState!.validate())
                            {
                              setState((){
                                const DisplayListings();
                                Navigator.pop(context);
                              });
                            }
                          else if(mounted && getMyLocationPressed == false && _formKey.currentState!.validate())
                            {
                              await _locationService.getLocationFromZipCode(enterZipCode.text); //save the userLatitude and longitude in sharedPreferences
                                  setState(() {
                                   const  DisplayListings();
                                    Navigator.pop(context);
                                  } );
                            }
                          else
                            {
                              Navigator.pop(context);
                            }
                            },
                        icon:  Icon(
                          custom_icons.MyFlutterApp.ok_circled,
                          size: screenWidth/12,
                          color: Colors.black,)),

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
