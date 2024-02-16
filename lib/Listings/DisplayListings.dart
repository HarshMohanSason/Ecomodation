
import 'package:ecomodation/AppSettings/AppSettingsService.dart';
import 'package:ecomodation/Listings/DetailedListing.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import 'package:flutter/material.dart';
import '../Auth/InternetChecker.dart';
import '../main.dart';
import 'ListingService.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';


class DisplayListings extends StatefulWidget {
  const DisplayListings({Key? key}) : super(key: key);

  @override
  State<DisplayListings> createState() => _DisplayListingsState();
}

class _DisplayListingsState extends State<DisplayListings> {

  final ListingService _listingService = ListingService();

  List<Map<String, dynamic>> listingInfoList = [];
  @override
  void initState() {

    super.initState();
    checkInternet();
  }

  Future<void> checkInternet() async {
    CheckInternet checkInternet = CheckInternet();
    bool isConnected = await checkInternet.checkInternet();

    if (!isConnected) {
     const  Text("No internet connection");
    }
    else
    {
     const Text("internet connection found");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: colorTheme,
      body:  _displayListings(),
    );
  }

  Widget _displayListings() {

    var future =  _listingService.getTotalListingsPerUser();

    return FutureBuilder(
        future: future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                children:  [
                  Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text('Loading nearby listings...', style: TextStyle(
                      fontSize: screenWidth/28,
                    ),),
                  ),
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

                await Future.delayed(const Duration(seconds: 2));

                if(mounted) {
                  setState(() {
                    future = _listingService.getTotalListingsPerUser();
                  });
                }
               return Future(() => future);
              },

              child: ListView.builder(
                scrollDirection: Axis.vertical,
                itemCount: listingInfoList.length,
                itemBuilder: (context, index)
                 {
                  String docID = listingInfoList.keys.elementAt(index);
                  List<Map<String, dynamic>> listings = listingInfoList[docID] as List<Map<String, dynamic>>;
                  final DetailedListingsStore detailedListingsStore = DetailedListingsStore(docID, listings[index]);

                  return GestureDetector
                   (
                      onTap: ()
                       {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailedListingInfo(detailedListingsStore: detailedListingsStore)));
                       },
                      onDoubleTap: () async
                      {
                        showToastWidget(
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5.0),
                            ),

                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.favorite, size: screenWidth/5.5, color: Colors.redAccent),
                              ],
                            ),
                          ),

                          context: context,

                          animation: StyledToastAnimation.fade,
                          reverseAnimation: StyledToastAnimation.fade,
                          position: StyledToastPosition.center,
                          animDuration: Duration(seconds: 1),
                          duration: Duration(seconds: 2),
                        );

                        AppSettingsService().saveListing(detailedListingsStore);
                        },

                     child: Column(
                       children: [
                         buildListingWidget(listings[index]),
                       ],
                     )
                   );
                },
              ),
            );
          }
        }
    );
  }

  Widget buildListingWidget(Map<String, dynamic> listingInfo) {
    List<dynamic> imageUrls = listingInfo['imageInfoList'];
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
          child: ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            child: SizedBox(
              width: screenWidth - 30,
              height: screenHeight - 500,
              child: PageView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  String imageUrl = imageUrls[index];
                  return buildImageWidget(imageUrl);
                },
              )
            ),
          ),
        ),
    Padding(
      padding: const EdgeInsets.only(top:10, left: 25.0),
      child: Align(
          alignment: Alignment.topLeft,
          child: Text(listingInfo['Title'], style:
          const TextStyle(
            fontWeight: FontWeight.bold,
          ),),
      ),
    ),
    Padding(
      padding: const EdgeInsets.only(top:2, left: 25.0),
      child: Align(
          alignment: Alignment.topLeft,
          child: Text(listingInfo['Price']+ '/mo')),
    ),],
    );
  }

  Widget buildImageWidget(String imagePath) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Image.network(
        imagePath,
      ),
    );
  }

  
}

