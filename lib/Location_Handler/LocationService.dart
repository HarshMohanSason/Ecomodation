
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Auth/auth_provider.dart';
import '../LoginWithPhone.dart';
import '../OTPpage.dart';

class LocationService {

  Future<LocationPermission> getPermission() async { //Function to get User Permission for enabling Phone's location

    LocationPermission permission = await Geolocator.checkPermission(); //get the permission to for location initailly

      while (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) //looping until the permission is not granted
      {

        if (permission == LocationPermission.deniedForever) { //if no permission is granted, open the settings
          openAppSettings(); //open App Settings
          break;
        }

        if (!await Geolocator.isLocationServiceEnabled()) { //if the service is not enabled, make the user enter the location again
          // Request location permission
          permission = await Geolocator.requestPermission(); //get the permission from the user
        }
        else {
          break;
        }
      }
  return permission;//return the permission
  }

  //Function to get the current User's location
  Future<String?> getUserCurrentLocation() async {

    var permission =  await getPermission();  //get the permissions to enable the UserLocation


    //if the permission is while in User or always
    if(permission == LocationPermission.whileInUse || permission == LocationPermission.always) {

      try {
        Position position = await Geolocator.getCurrentPosition(); //get the current position
        await uploadLocationToFirebase(position.latitude, position.longitude); //upload the location to firebase

        await storeLocationSharedPref(position.latitude, position.longitude); //store the loaction in sharedPreferences

        //list to get the placeMarks
        List<Placemark> placeMarks = await placemarkFromCoordinates(position.latitude, position.longitude);

        Placemark zipcode = placeMarks[0]; //get the Zipcode

        return zipcode.postalCode; //return the zipCode
      }
      catch (e) { //catch any errors found
        rethrow;
      }
    }
    return null; //return null if no zipcode is retrieved
  }



 Future<dynamic> getLocationFromZipCode(String zipCode) async
 {
   try {
     if (zipCode.length == 6 || zipCode.length == 5) { // Make sure a valid zipCode is entered
       var locations = await locationFromAddress(
          zipCode); //get the list Locations

       print(locations);
       if (locations.isNotEmpty) //if the list is not empty
           {
         await uploadLocationToFirebase(locations.first.latitude, locations.first.longitude); //update the new location again to firebase

         await storeLocationSharedPref(locations.first.latitude, locations.first.longitude); //update the new location again in sharedPref

       }
     }
   }
   catch(e)
   {
     rethrow;
   }


 }

 //function to upload the location to firebase
 Future uploadLocationToFirebase(double? latitude, double? longitude) async {

   try {

     if (loggedInWithPhone == true) {
       await FirebaseFirestore.instance.collection('userInfo').doc(phoneLoginDocID).update({
         'Latitude': latitude!,
         'Longitude': longitude!,
       });
     }

     else if (loggedInWithGoogle == true) {
       await FirebaseFirestore.instance.collection('userInfo').doc(googleLoginDocID).update({
         'Latitude': latitude,
         'Longitude': longitude,
       });
     }

     // Handle success, if needed
   } catch (e) {
     // catch errors here.
     // print('Error updating location: $e');
   }
 }



 Future<void> storeLocationSharedPref(double? latitude, double? longitude) async
 {
   try
   {
   final storeData = await SharedPreferences.getInstance(); //get the sharedPref Instance

   await storeData.setDouble('Latitude', latitude!); //set the latitude value to sharedPref
   await storeData.setDouble('Longitude', longitude!); //set the longitude value to sharedPref
    }
 catch(e)
   {
     rethrow;
   }
 }

}



