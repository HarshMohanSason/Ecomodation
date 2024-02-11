
import 'package:ecomodation/AppSettings/AppSettingsService.dart';
import 'package:flutter/material.dart';

import '../main.dart';

class YourListing extends StatefulWidget{

    const YourListing({Key? key}) : super(key: key);

    @override
    State<YourListing> createState() => _YourListingState();
}

class _YourListingState extends State<YourListing> {

  late dynamic futureYourListingInfo;

  @override
  void initState()
  {
    getListingData();
    super.initState();
  }

  Future<void> getListingData() async
  {
    AppSettingsService appSettingsService = AppSettingsService();
    futureYourListingInfo = await appSettingsService.yourListings();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.white,

      body: Expanded(

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
                   itemBuilder: (context, index)
                  {

                  }
                  );
                }

             },
         )
      ),
    );
  }

Widget listingListDisplay(Map<String, dynamic> listingDetails)
{
   if(listingDetails.isNotEmpty){
    return InkWell(

      onTap: null,

      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [

        Container(
        width: screenWidth / 12.5,
        child: ClipOval(
          child: Image.network(listingDetails['imageInfoList'].first),
        ),
      ),
          Column(
            children: [
              Text(
                listingDetails['Title']
              ),

              ElevatedButton(
                  onPressed: null,
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.0),
                        )),
                    fixedSize: MaterialStateProperty.all(
                        Size(screenWidth/3, screenHeight / 21)),
                    backgroundColor: const MaterialStatePropertyAll(
                        Colors.red), //set the color for the continue button
                  ),
                  child: const Text(
                    'Mark as Rented',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
              ),
              Divider(),
         ],
          )
        ],

      ),

    );
}
   else
     {
       return const Center(child: Text("You do not have any listings yet. Upload some listings first"));
     }
  }

}