
import 'package:ecomodation/Listings/DisplayListings.dart';
import 'package:ecomodation/Location_Handler/LocationService.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'CustomIcons/my_flutter_app_icons.dart' as custom_icons;


class HomeScreenUI extends StatefulWidget {

  double _currentSliderValue = 5;
  double get enteredDistanceRange => _currentSliderValue;
  set distanceRange(double range) =>  _currentSliderValue = range;

  // final String imagePath;
   HomeScreenUI({Key? key}) : super(key: key);

  @override
  State<HomeScreenUI> createState() => _HomeScreenUIState();
}


class _HomeScreenUIState extends State<HomeScreenUI> {


  final HomeScreenUI _mainScreen = HomeScreenUI();

  final LocationService _locationService = LocationService();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController enterZipCode = TextEditingController();


  @override
  void initState()
  {
    super.initState();
    _locationService.getPermission();
  }


//function to get the currentUserLocation Whenever the "Get my Location" button is tapped

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: colorTheme,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
           const Padding(padding: EdgeInsets.only(top:50)),
            _locationWidget(),
              Align(
               alignment: Alignment.topCenter,
                 child: Text('Listings near you', style: TextStyle(
                   fontSize: screenWidth/17,
                   fontWeight: FontWeight.bold,
                 ),)),
            const Expanded(
               child: DisplayListings()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                  padding: const EdgeInsets.only(bottom: 25),
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
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () => {},
            icon: Icon(Icons.home, color: Colors.black, size: sizeofIcons),
          ),
        ),
       const Spacer(),
        Align(
          alignment: Alignment.topLeft,
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
          alignment: Alignment.topLeft,
          child: IconButton(
            onPressed: () => Navigator.pushNamed(context, 'HomeScreenMessagingUI'),
            icon: Icon(Icons.messenger_rounded, color: Colors.black, size: sizeofIcons),
          ),
        ),
      const  Spacer(),
        Align(
          alignment: Alignment.topLeft,
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

    bool getMyLocationPressed = false;

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

                      var zipCode = await _locationService.getUserCurrentLocation();

                      setState(() {
                        enterZipCode.text = zipCode!; //fill the zipcode text box with the current  zip code
                        getMyLocationPressed = true;
                      });
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
                          if(getMyLocationPressed == true) //if the user has pressed the getMyLocation, get automatic location
                          {
                            await _locationService.getUserCurrentLocation(); //call the getUserCurrentLocation()
                          }
                          else if(enterZipCode.text.isNotEmpty && _formKey.currentState!.validate()) //get the location from zipCode if manually entered
                          {
                            await _locationService.getLocationFromZipCode(enterZipCode.text); //call the getLocationFromZipCode
                          }
                           if(mounted && _formKey.currentState!.validate()) {
                             Navigator.pop(context);
                           }
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
