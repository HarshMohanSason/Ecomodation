
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecomodation/AddListingsUI/AddDescription.dart';
import 'package:ecomodation/AddListingsUI/AddListing.dart';
import 'package:ecomodation/AddListingsUI/ListingPrice.dart';
import 'package:ecomodation/AppSettings/AppSettingsService.dart';
import 'package:ecomodation/AppSettings/YourListings/DisplayOwnListing.dart';
import 'package:ecomodation/Listings/DetailedListingsStore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../main.dart';

class YourListing extends StatefulWidget{

    const YourListing({Key? key}) : super(key: key);

    @override
    State<YourListing> createState() => _YourListingState();
}

class _YourListingState extends State<YourListing> {

  late var futureYourListingInfo;

  @override
  void initState()
  {
    getListingData();
    super.initState();
  }

  Future<void> getListingData() async
  {
    AppSettingsService appSettingsService = AppSettingsService();
    futureYourListingInfo =  appSettingsService.yourListings();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

       appBar: AppBar(
         title: const Text("Your Listings",
         style: TextStyle(
           fontSize: 28,
         )),
         leading: IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios)),
       ),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: FutureBuilder(
               future: futureYourListingInfo,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {

                 if(snapshot.connectionState == ConnectionState.waiting)
                   {
                     return Center(
                       child: Text('Loading your listings...', style: TextStyle(
                         fontSize: screenWidth/28,
                       ),),
                     );
                   }
                 if(snapshot.hasError)
                   {
                     return Center(
                       child: Text('Could not fetch your listings', style: TextStyle(
                         fontSize: screenWidth/28,
                       ),),
                     );
                   }
                 else if(snapshot.hasData && (snapshot.data as Map<String, Map<String, dynamic>>).isEmpty)
                 {
                   return  Center(child:Text('You do not have any listings yet. Upload some first', style: TextStyle(
                     fontSize: screenWidth/27,
                   ),));
                 }
                 else
                   {
                     List<Map<String, Map<String, dynamic>>> listingInfo = [];


            // Assuming snapshot.data is of type Map<String, Map<String, dynamic>>
                     snapshot.data!.forEach((key, value) {
                       listingInfo.add({key: value});
                     });

                     return ListView.builder(
                       scrollDirection: Axis.vertical,
                       itemCount: listingInfo.length,
                       shrinkWrap: true,
                      itemBuilder: (context, index)
                     {
                          return listingsDisplay(listingInfo[index].values.first, listingInfo[index].keys.first);
                     }
                     );
                   }
                },
            ),
          ),
        ],
      ),
    );
  }

  Widget listingsDisplay(Map<String, dynamic> listingDetails, String docID) {

    if (listingDetails.isNotEmpty) {

      return InkWell(
        onTap: () {
          DetailedListingsStore detailedListingsStore = DetailedListingsStore(docID, listingDetails);
          Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayOwnListing(detailedListingsStore: detailedListingsStore)));
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Container(
            height: screenHeight/7,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
           child: Row(
              children: [
                ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      child: CachedNetworkImage(
                        imageUrl: listingDetails['imageInfoList'].first.toString(),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: VerticalDivider( // Vertical line
                    color: Colors.grey.withOpacity(0.8),
                    thickness: 2,
                    width: 1,
                    indent: 10, // Adjust the space from the top
                    endIndent: 10, // Adjust the space from the bottom
                  ),
                ),
               Expanded(
                 child: Padding(
                   padding: EdgeInsets.only(left: 10),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Padding(
                         padding: EdgeInsets.only(top: 15),
                         child: Text(
                          listingDetails['Title'],
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                                       ),
                       ),
                       Spacer(),
                       if (listingDetails['Rented'] == false)
                         Center(
                           child: Padding(
                             padding: EdgeInsets.only(bottom: 10),
                             child: InkWell(
                               onTap: () {
                                 if (mounted) {
                                   markAsRentedOrCancel(context);
                                 }
                               },
                               child: const Text(
                                 'Mark Rented',
                                 style: TextStyle(
                                   color: Colors.red,
                                   fontWeight: FontWeight.bold,
                                   fontSize: 16,
                                 ),
                               ),
                             ),
                           ),
                         ), ],
                   ),
                 ),
               ),

           ] ),

          ),
        ),
      );
    } else {
      return Center(child: Text("You do not have any listings yet. Upload some listings first"));
    }
  }

  Future markAsRentedOrCancel(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: SizedBox(
            height: screenWidth/1.5,
            width: screenWidth - 10,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon( Icons.error_outline,
                    color: Colors.red,
                    size: screenWidth/5.5),
                Padding(
                  padding:  EdgeInsets.only(top: screenWidth/27),
                  child: Text(
                    'Mark Listing as Rented?',
                    style: TextStyle(
                      fontSize: screenWidth/20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to mark this listing as rented? This action cannot be undone.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      icon: Icon(
                        Icons.close_outlined, // Using the close icon
                        color: Colors.red, // Red color for the icon
                        size: screenWidth/9, // Adjust the size of the icon as needed
                      ),
                    ),
                    IconButton(
                      onPressed: () async
                      {
                        if (mounted) {
                          bool markRented = await AppSettingsService().updateMarkRented(true);
                          if (markRented) {
                            Fluttertoast.showToast(
                              msg: 'Your listing was marked as rented!',
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 3,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.green,
                              textColor: Colors.white,
                            );
                            Navigator.pop(context); // Close the dialog
                          } else {
                            Fluttertoast.showToast(
                              msg: 'Could not mark listing as rented. Please try again.',
                              toastLength: Toast.LENGTH_LONG,
                              timeInSecForIosWeb: 4,
                              gravity: ToastGravity.CENTER,
                              backgroundColor: Colors.red,
                              textColor: Colors.white,
                            );
                          }
                        }

                      }, icon: Icon(Icons.done,
                    color: Colors.green,
                    size: screenWidth/9,),
                    )
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }



}