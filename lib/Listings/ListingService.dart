import 'package:ecomodation/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';



class ListingService {

  final MainScreen _mainScreen = MainScreen();
  var readUserInfo = FirebaseFirestore.instance.collection('userInfo');

  double calculateDistance(double currentUserLatitude, double currentUserLongitude, double otherUserLatitude,
      double otherUserLongitude) {
    const double earthRadius = 6371.0;

    // Haversine formula
    double dLat = currentUserLatitude -  otherUserLatitude;
    double dLon = currentUserLongitude - otherUserLongitude;
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(currentUserLatitude) * cos(otherUserLatitude) * sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = earthRadius * c;

    return distance;

  }


  Future<List<String>> getDistances() async
  {
    List<String> filteredListingIDs = [];
    var document = await readUserInfo.get();

    for (var snapshot in document.docs) {
      Map<String, dynamic> data = snapshot.data();

      if (data.containsKey('Latitude') && data.containsKey('Longitude')) {
        double otherUserLatitude = data['Latitude'];
        double otherUserLongitude = data['Longitude'];

        var getDistance = calculateDistance(_mainScreen.getLatitude, _mainScreen.getLongitude, otherUserLatitude, otherUserLongitude);


      //  if (getDistance >= 0 && getDistance <= _mainScreen.enteredDistanceRange)
            {
               filteredListingIDs.add(snapshot.id);
            }
      }
    }
    return filteredListingIDs;
  }

  Future<Map<String, List<Map<String, dynamic>>>> getTotalListingsPerUser() async
  {
     List<String> filteredListingIDs = []; //initialize the filteredListingIDs
     filteredListingIDs = await getDistances(); // Wait to get the entire list of doc IDs.
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



