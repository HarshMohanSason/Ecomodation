
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

Widget listingsDisplay(Map<String, dynamic> listingDetails, String docID)
{
   if(listingDetails.isNotEmpty)
   {

    return InkWell(
      onTap: ()
      {
        DetailedListingsStore detailedListingsStore = DetailedListingsStore(docID, listingDetails);
        Navigator.push(context, MaterialPageRoute(builder: (context) => DisplayOwnListing(detailedListingsStore: detailedListingsStore)));
      },

      child: Padding(

        padding: const EdgeInsets.only(top: 30, left: 20),

        child: Column(
          children: [
            Row(

              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [


              SizedBox(
              width: screenWidth / 6.5,
              child: ClipRect(
                child: CachedNetworkImage(imageUrl: listingDetails['imageInfoList'].first.toString()),
              ),
            ),

                Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Text(
                          listingDetails['Title'],
                          style: TextStyle(
                            fontSize: screenWidth/28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      if(listingDetails['Rented'] == false) ...[
                      InkWell(
                        onTap: () async
                          {
                            if(mounted)
                              {
                                markAsRentedOrCancel(context);
                              }

                            },
                          child: const Text(
                            'Mark Rented',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                      ),

                              ]
                    ],
                  ),

                ),
               const Spacer(),
                Padding(
                    padding: const EdgeInsets.only(right: 5),

                    child: InkWell(
                        onTap: () {

                          if(mounted)
                            {
                              List<dynamic> dynamicList = listingDetails['imageInfoList'];
                              AddDescription.descriptionController.text = listingDetails['Description'];
                              AddDescription.titleController.text = listingDetails['Title'];
                              ListingPrice.phoneText.text = listingDetails['Price'];
                              AddListing.allImages = List<String>.from(dynamicList); // Convert dynamicList to a List<String>
                              Navigator.pushNamed(context, 'ListingProgressBar');
                            }

                        },
                        child: const Icon(Icons.edit,))),
              ],

            ),
            const Divider(),
          ],
        ),
      ),

    );
}
   else
     {
       return const Center(child: Text("You do not have any listings yet. Upload some listings first"));
     }
  }

  /* Widget to make the mark rented or cancel popup */
  Future markAsRentedOrCancel(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: SizedBox(
            height: screenHeight / 6,
            child: Center(
              child: Column(
                children: [
                  const Text(
                    'Are you sure you want to mark this listing as rented? Note this action cannot be undone',
                    style: TextStyle(fontSize: 13),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 23),
                    child: Row(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context); //get out of the widget
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.grey),
                              fixedSize: MaterialStateProperty.all(
                                Size(screenWidth / 3.3, screenWidth / 43.2),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        Align(
                          alignment: Alignment.centerRight,
                          child: ElevatedButton(
                            onPressed: () async{
                              if(mounted)
                                {
                                  bool markRented = await  AppSettingsService().updateMarkRented(true); //mark the listing rented

                                  if(markRented == true) //if successful
                                    {
                                      Fluttertoast.showToast( //display toast to user showing that the listing wasmarked rented
                                        msg: 'Your listing was marked rented!',
                                        toastLength: Toast.LENGTH_LONG,
                                        timeInSecForIosWeb: 3,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                      );
                                      if(mounted) {
                                        Navigator.pop(context);
                                      }
                                    }
                                  else
                                    {
                                      Fluttertoast.showToast( //display toast to user showing that the listing wasmarked rented
                                        msg: 'Could not Mark Listing Rented, try again!',
                                        toastLength: Toast.LENGTH_LONG,
                                        timeInSecForIosWeb: 4,
                                        gravity: ToastGravity.CENTER,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                      );
                                    }

                                };
                            },
                            style: ButtonStyle(
                              backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                              fixedSize: MaterialStateProperty.all(
                                Size(screenWidth / 3.3, screenWidth / 43.2),
                              ),
                            ),
                            child: const Text(
                              'Mark Rented',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }



}