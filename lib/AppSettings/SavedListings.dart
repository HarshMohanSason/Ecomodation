
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
      backgroundColor: Colors.white,
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

                          return InkWell(
                              onTap: ()
                              {
                                if(isEditing) {
                                  setState(() {
                                    if (boxColor == Colors.blueAccent) {
                                      boxColor = Colors.white;
                                      boxBorderColor = Colors.grey;
                                    }
                                    else {
                                      boxBorderColor = Colors.blueAccent;
                                      boxColor = Colors.blueAccent;
                                      selectedItems.add(savedListings[index]);
                                    }
                                  });
                                }
                              },
                              child: displaySavedListings(savedListings[index], index));
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
  Widget displaySavedListings(Map<String, dynamic> map, int index) {

    if (map.isNotEmpty) {
      return InkWell(
        onTap: () {
          if(!isEditing)
            {
            DetailedListingsStore detailedListingsStore = DetailedListingsStore(
                map['docID'], map);
            Navigator.push(context, MaterialPageRoute(builder: (context) =>
                DetailedListingInfo(
                    detailedListingsStore: detailedListingsStore)));
          }
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isEditing) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: SizedBox(
                      width: screenWidth/15,
                      height: screenWidth/15,
                      child: createSelectButtons(),
                    ),
                  ),
                ],
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: SizedBox(
                    child: Image.network(
                      map['imageInfoList'].first.toString(),
                      fit: BoxFit.cover,
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
                    padding: const EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        Text(
                          map['Title'],
                          style:  TextStyle(
                            fontSize: screenWidth/25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 20),
                          child: Text(
                            map['Price'],
                            style:  TextStyle(
                              fontSize: screenWidth/30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } else {
      return const Center(
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


  Widget createSelectButtons()
  {
     if(isEditing) {
             return Padding(
               padding: const EdgeInsets.only(top: 10),
               child: Container(
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
             );
     }
     else
       {
         return Container();
       }
  }

  Future deleteSavedListing()
  {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 5,
          shadowColor: Colors.black,
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // Adjust the circular border radius
          ),
          contentPadding: const EdgeInsets.all(20),
          content: SafeArea(
            child: SizedBox(
              height: screenHeight / 4,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon( Icons.error_outline,
                      color: Colors.red,
                      size: screenWidth/5.5),
                  Padding(
                    padding:  EdgeInsets.only(top: screenWidth/27),
                    child: Text(
                      'Delete the selected saved Listings?',
                      style: TextStyle(
                        fontSize: screenWidth/28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(bottom: screenWidth / 17),
                    child: Row(
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
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                side: const BorderSide(
                                  color: Colors.red, // Red border color
                                  width: 1.0, // Adjust the border width as needed
                                ),
                              ),
                            ),
                            backgroundColor: MaterialStateProperty.all<Color>(Colors.white), // White background color
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(screenWidth / 3.5, screenWidth / 43.2),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
                              if(mounted) {
                                Navigator.pop(context); // Close the dialog
                              }
                            }
                          },

                          style: ButtonStyle(
                            fixedSize: MaterialStateProperty.all<Size>(
                              Size(screenWidth / 3.5, screenWidth / 43.2)),
                            backgroundColor: MaterialStateProperty.all(Colors.red),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                          child: const Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
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
