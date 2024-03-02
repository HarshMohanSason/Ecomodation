
import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecomodation/AppSettings/AppSettingsService.dart';
import 'package:ecomodation/Listings/DetailedListing.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../Listings/DetailedListingsStore.dart';
import '../main.dart';


class SavedListings extends StatefulWidget
{
  const SavedListings({Key? key}) : super(key: key);

  @override
  State<SavedListings> createState() => _SavedListingState();
}

class _SavedListingState extends State<SavedListings> {

  late var savedListingsFuture;
  List<Map<String, dynamic>> savedListings = [];
  List<Map<String, dynamic>> selectedItems = [];
  AppSettingsService appSettingsService = AppSettingsService();
  Color boxColor = Colors.white;
  Color boxBorderColor = Colors.grey;

  bool isEditing = false;

  @override
  void initState() {

    fetchSavedListings();

    super.initState();
  }

  Future<void> fetchSavedListings() async
  {
    AppSettingsService appSettingsService = AppSettingsService();
    savedListingsFuture = appSettingsService.getSavedListing();
  }



  void toggleEdit(bool setValue)
  {
    setState(() {
      isEditing = setValue; //set the editing variable to true
      selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context)
  {
    return Scaffold(

        appBar: AppBar(
          title: const Text("Saved Listings",
              style: TextStyle(
                fontSize: 28,
              )),
          leading: IconButton(onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_ios)
          ),
          actions: [

            if(!isEditing) ...[
              IconButton(
                onPressed: () {
                  if(savedListings.isNotEmpty) { //make sure there is something to edit in the list
                    toggleEdit(true); //toggle the edit action
                  }
                  else
                    {
                      null;
                    }
                },
                icon: const Icon(Icons.edit, color: Colors.black,),
              ),
            ]

            else...[
              InkWell(
                  onTap: ()
                  {
                    toggleEdit(false);
                    boxColor = Colors.white;
                    boxBorderColor = Colors.grey;
                  },

                  child: Padding(
                    padding: const EdgeInsets.only(right: 5.0),
                    child: Text("Done", style: TextStyle(
                      fontSize: screenWidth/25,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.bold,
                    ),),
                  )
              )

            ]
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [

            Expanded(
              child: FutureBuilder(
                future: savedListingsFuture,
                builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Text('Loading saved listings...', style: TextStyle(
                        fontSize: screenWidth / 28,
                      ),),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Could not fetch saved listings', style: TextStyle(
                        fontSize: screenWidth / 28,
                      ),),
                    );
                  }
                  else if (snapshot.hasData &&
                      (snapshot.data as List<Map<String, dynamic>>)
                          .isEmpty) {
                    return Center(
                        child: Text('No saved Listings', style: TextStyle(
                          fontSize: screenWidth / 27,
                        ),));
                  }
                  else {
                    savedListings = snapshot.data as List<Map<String, dynamic>>;
                    return ListView.builder(
                        scrollDirection: Axis.vertical,
                        itemCount: savedListings.length,
                        shrinkWrap: true,
                        itemBuilder: (context, index) {
                          return displaySavedListings(savedListings[index]);
                        }
                    );
                  }
                },
              ),
            ),
            if (isEditing)...[
              Align(
                alignment: Alignment.bottomRight,
                child:  Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: InkWell(
                    onTap: () async
                    {
                      if(mounted && selectedItems.isNotEmpty)
                        {
                          deleteSavedListing();
                        }

                    },
                    child:  Text(
                      'Delete',
                      style: TextStyle(
                          fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: selectedItems.isNotEmpty ? Colors.blueAccent : Colors.grey),
                    ),
                  ),
                ),
              ),
                ]
          ],
        )
    );
  }
  Widget displaySavedListings(Map<String, dynamic> map) {
    if (map.isNotEmpty) {
      return InkWell(
        onTap: () {
          DetailedListingsStore detailedListingsStore = DetailedListingsStore(
              map['docID'], map);
          Navigator.push(context, MaterialPageRoute(builder: (context) =>
              DetailedListingInfo(detailedListingsStore: detailedListingsStore)));
        },
        child: Padding(
          padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing)
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: createSelectButtons(),
                    ),
                  ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    width: 100,
                    child: CachedNetworkImage(
                      imageUrl: map['imageInfoList'].first.toString(),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),
                      Text(
                        map['Title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Text(
          "You do not have any saved listings here. Double tap on a listing to save it",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
  }



  Widget createSelectButtons( )
  {
     if(isEditing) {

       return ListView.builder(

           scrollDirection: Axis.vertical,
           itemCount: savedListings.length,
           shrinkWrap: true,

           itemBuilder: (context, index) {

             return InkWell(

               onTap: ()
               {
                 setState(()
                 {
                   if(boxColor == Colors.blueAccent)
                     {
                        boxColor = Colors.white;
                        boxBorderColor = Colors.grey;
                     }
                   else
                   {
                       boxBorderColor = Colors.blueAccent;
                       boxColor = Colors.blueAccent;
                       selectedItems.add(savedListings[index]);
                   }
                 });
               },
               child: Padding(
                 padding: const EdgeInsets.only(top: 10),
                 child: Container(
                   width: screenWidth/22,
                   height: screenWidth/22,
                   margin: const EdgeInsets.symmetric(horizontal: 4),
                   decoration: BoxDecoration(
                     color: boxColor,
                     shape: BoxShape.circle,
                     border: Border.all(
                       color: boxBorderColor,
                       width: 2,
                     ),
                   ),
                 ),
               ),
             );
           }
       );
     }
     else
       {
         return Container();
       }
  }

  Future deleteSavedListing() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Delete the following saved Listings?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      toggleEdit(false);
                      boxBorderColor = Colors.grey;
                      boxColor = Colors.white;
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.grey),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    child: Text(
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
                        await appSettingsService.deleteSavedListings(selectedItems);
                        setState(() {
                          for (int i = savedListings.length - 1; i >= 0; i--) {
                            if (selectedItems.length > i && selectedItems[i] == savedListings[i]) {
                              savedListings.removeAt(i);
                              selectedItems.removeAt(i);
                            }
                          }
                          isEditing = false;
                          boxColor = Colors.white;
                          boxBorderColor = Colors.grey;
                          selectedItems.clear();
                        });
                        Fluttertoast.showToast(
                          msg: 'Saved Listings removed',
                          toastLength: Toast.LENGTH_LONG,
                          timeInSecForIosWeb: 3,
                          gravity: ToastGravity.CENTER,
                          backgroundColor: Colors.green,
                          textColor: Colors.white,
                        );
                        Navigator.pop(context); // Close the dialog
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
                      'Delete',
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
        );
      },
    );
  }

}

