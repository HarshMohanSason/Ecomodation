import 'package:ecomodation/Listings/DetailedListing.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import 'package:flutter/material.dart';
import '../main.dart';
import 'ListingService.dart';


class DisplayListings extends StatefulWidget {
  const DisplayListings({Key? key}) : super(key: key);

  @override
  State<DisplayListings> createState() => _DisplayListingsState();
}

class _DisplayListingsState extends State<DisplayListings> {

  final ListingService _listingService = ListingService();

  List<Map<String, dynamic>> listingInfoList = [];


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: colorTheme,
      body:  _displayListings(),
    );
  }

  Widget _displayListings() {

    return FutureBuilder(

        future: _listingService.getTotalListingsPerUser(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                children:  [
                  SizedBox(height: screenHeight/40),
                  Text('Loading nearby listings...', style: TextStyle(
                    fontSize: screenWidth/28,
                  ),),
                ],
              ),
            );
          }

          else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          else if (snapshot.hasData && (snapshot.data as Map<String, List<Map<String, dynamic>>>).isEmpty) {
              return  Center(child:Text('No listings nearby :(', style: TextStyle(
                fontSize: screenWidth/27,
              ),));
            }

          else {
            Map<String, List<Map<String, dynamic>>> listingInfoList = snapshot.data as Map<String, List<Map<String, dynamic>>>;

            return RefreshIndicator(
              color: Colors.black,
              backgroundColor: colorTheme,
              onRefresh: () async {

                await Future.delayed(Duration(seconds: 2));
              },
              child: ListView.builder(
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: listingInfoList.length,
                itemBuilder: (context, index)
                 {
                  String docID = listingInfoList.keys.elementAt(index);
                  List<Map<String, dynamic>> listings = listingInfoList[docID] as List<Map<String, dynamic>>;
                  final DetailedListingsStore detailedListingsStore = DetailedListingsStore(docID, listings[index]);
                  return GestureDetector
                   ( onTap: ()
                       {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedListingInfo(detailedListingsStore: detailedListingsStore)));
                       },
                     child: buildListingWidget(listings[index])
                   );
                },
              ),
            );
          }
        }

    );
  }


  Widget buildListingWidget(Map<String, dynamic> listingInfo) {

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        color: Colors.transparent,
        width: screenWidth - 20,
        height: screenHeight - 450,
        child: listingInfo != null
            ? PageView.builder(
          itemCount: listingInfo['imageInfoList'].length,
          itemBuilder: (context, index) {
            Map<String,
                dynamic> imageInfo = listingInfo['imageInfoList'][index];
            String imageUrl = imageInfo['url']; // Correct the field name
            double rotationAngle = imageInfo['rotationAngle'];
            return buildImageWidget(imageUrl, rotationAngle);
          },
        )
            : null,
      ),
    );
  }

  Widget buildImageWidget(String imagePath, double rotationAngle) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Image.network(
          // scale: addListingState.zoomLevel,
          imagePath,
        ),
      ),
    );
  }


}

