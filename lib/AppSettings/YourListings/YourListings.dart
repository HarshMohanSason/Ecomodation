
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
        child: Card(
          color: Colors.black,
          elevation: 8,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 120,
                  child: CachedNetworkImage(
                    imageUrl: listingDetails['imageInfoList'].first.toString(),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              title: Text(
                listingDetails['Title'],
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30),
                  if (listingDetails['Rented'] == false)
                    InkWell(
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
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white,),
                onPressed: () {
                  if (mounted) {
                    List<dynamic> dynamicList = listingDetails['imageInfoList'];
                    AddDescription.descriptionController.text = listingDetails['Description'];
                    AddDescription.titleController.text = listingDetails['Title'];
                    ListingPrice.phoneText.text = listingDetails['Price'];
                    AddListing.allImages = List<String>.from(dynamicList);
                    Navigator.pushNamed(context, 'ListingProgressBar');
                  }
                },
              ),
            ),
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
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text(
                  'Mark Listing as Rented?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                Text(
                  'Are you sure you want to mark this listing as rented? This action cannot be undone.',
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close the dialog
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.grey),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
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
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      child: Text(
                        'Mark Rented',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
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