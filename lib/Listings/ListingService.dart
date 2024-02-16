
import 'package:ecomodation/Auth/auth_provider.dart';
import '../phoneLogin/LoginWithPhone.dart';
import 'package:ecomodation/phoneLogin/OTPpage.dart';
import 'package:ecomodation/homeScreenUI.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class ListingService {

  final HomeScreenUI _mainScreen = HomeScreenUI(); //instance of HomescreenUI


  var readUserInfo = FirebaseFirestore.instance.collection('userInfo'); //Collection reference to collection UserInfo

  //Function to get the listings within the user's entered location and distance
  //Takes the currentUser Latitude and Longitude and will return listings within a certain distance (km)

  double calculateDistance(double currentUserLatitude, double currentUserLongitude, double otherUserLatitude,
      double otherUserLongitude) {
    const double earthRadius = 6371.0; //constant earth radius

    // Convert degrees to radians
    currentUserLatitude = _degreesToRadians(currentUserLatitude);
    currentUserLongitude = _degreesToRadians(currentUserLongitude);
    otherUserLatitude = _degreesToRadians(otherUserLatitude);
    otherUserLongitude = _degreesToRadians(otherUserLongitude);

    // Calculate the distance between two locations using the Haversine formula
    double dLat = currentUserLatitude - otherUserLatitude;
    double dLon = currentUserLongitude - otherUserLongitude;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(currentUserLatitude) * cos(otherUserLatitude) * sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    double distance = earthRadius * c;

    return distance;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180.0);
  }
  //Function to get read Distances of all users
  Future<List<String>> getListingsInUserDistance() async
  {
    List<String> filteredListingIDs = []; //initialize an empty list
    late dynamic document;

    if(loggedInWithGoogle) {
     document = await readUserInfo.where(FieldPath.documentId, isNotEqualTo: googleLoginDocID) // Exclude current user's document
          .get();
    }

    else if(loggedInWithPhone)
      {
       document = await readUserInfo.where(FieldPath.documentId, isNotEqualTo: phoneLoginDocID) // Exclude current user's document
            .get();
      }

    final readData = await SharedPreferences.getInstance(); //instance for the shared preferences;
    var  userLatitude = readData.getDouble('Latitude'); //userLatitude
    var  userLongitude = readData.getDouble('Longitude'); //userLongitude
    var  userDistance = readData.getInt('userDistance');

    for (var snapshot in document.docs) {
      
        Map<String, dynamic> data = snapshot.data(); //get the snapshot of the data
      
      if (data.containsKey('Latitude') && data.containsKey('Longitude')) { //if it contains latitude || longitude, return the latitude and longitude values
        double otherUserLatitude = data['Latitude']; //get the latitude
        double otherUserLongitude = data['Longitude']; //get the longitude

        var getDistance = calculateDistance(userLatitude!, userLongitude!, otherUserLatitude, otherUserLongitude); //calculate the distance using the function above

        if (getDistance >= 0 && getDistance <= userDistance!) //if the distance is within the range which user entered
            {
               filteredListingIDs.add(snapshot.id); //add the Listing ID to show to display the listings
            }

      }
    }
    return filteredListingIDs; //return the filteredListingIDs.
  }

  Future<Map<String, List<Map<String, dynamic>>>> getTotalListingsPerUser() async
  {
     List<String> filteredListingIDs = []; //initialize the filteredListingIDs
     filteredListingIDs = await getListingsInUserDistance(); // Wait to get the entire list of doc IDs.
     Map<String, List<Map<String, dynamic>>> eachListing = {};
     List<Map<String, dynamic>> newListing = [];
      for (var i = 0; i < filteredListingIDs.length; i++)
      {
        var document = await readUserInfo.doc(filteredListingIDs[i]).collection('ListingInfo').get();
         {
               for (var snapshot in document.docs)
               {
                 newListing.add(snapshot.data());
                 eachListing[snapshot.id] = newListing;
               }
         }
  }
    return eachListing;
 }


}



