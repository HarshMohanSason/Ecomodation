
import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:flutter/material.dart';
import 'package:ecomodation/main.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import '../../AddListingsUI/AddDescription.dart';
import '../../AddListingsUI/AddListing.dart';
import '../../AddListingsUI/ListingPrice.dart';
import '../../Listings/DetailedListingsStore.dart';
import '../../Listings/FullImageView.dart';

class DisplayOwnListing extends StatefulWidget {

  final DetailedListingsStore detailedListingsStore;

  const DisplayOwnListing({Key? key, required this.detailedListingsStore}) : super(key: key);

  @override
  State<DisplayOwnListing> createState() => _DisplayOwnListingState();
}

class _DisplayOwnListingState extends State<DisplayOwnListing> {

  final MessageService _messageService = MessageService();
  final  _currentPageNotifier = ValueNotifier<int>(0);


  @override
  void initState() {

    super.initState();
  }


  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(
              height: screenHeight,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Stack(children: [
                    _buildListing(widget.detailedListingsStore.listingInfo),
                    Padding(
                      padding: const EdgeInsets.only(top: 60, left: 10),
                      child: Align(
                          alignment: Alignment.topLeft,
                          child: InkWell(
                              onTap: () => Navigator.pop(context),
                              child: Icon(Icons.arrow_circle_left_rounded, size: screenWidth/8, color: colorTheme,))

                      ),
                    ),
                  ]),
                  const  SizedBox(height: 20),
                  Center(child: circleIndicator()),
                  const SizedBox(height: 20),
                  Align(
                    alignment: const Alignment(-0.9, 0),
                    child: Text(widget.detailedListingsStore.listingInfo['Title'],
                        style: TextStyle(
                          fontSize: screenWidth / 13,
                        )),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: const Alignment(-0.9, 0),
                    child: Text(widget.detailedListingsStore.listingInfo['Price'],
                        style: TextStyle(
                          fontSize: screenWidth/13,
                          fontWeight: FontWeight.bold,
                        ) ),
                  ),

                  const SizedBox(height: 20),

                  Align(
                    alignment: const Alignment(-0.9, 0),
                    child: Text('Description:' + ' ' +  widget.detailedListingsStore.listingInfo['Description'],
                        style: TextStyle(
                          fontSize: screenWidth/25,
                        ) ),
                  ),

                  const Spacer(),

                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 20),
                    child: IconButton(
                    icon:  Icon(Icons.edit, color: Colors.black,
                    size: screenWidth/9),
                    onPressed: () {
                      if (mounted) {
                        List<dynamic> dynamicList = widget.detailedListingsStore.listingInfo['imageInfoList'];
                        AddDescription.descriptionController.text =  widget.detailedListingsStore.listingInfo['Description'];
                        AddDescription.titleController.text =  widget.detailedListingsStore.listingInfo['Title'];
                        ListingPrice.phoneText.text =  widget.detailedListingsStore.listingInfo['Price'];
                        AddListing.allImages = List<String>.from(dynamicList);
                        Navigator.pushNamed(context, 'ListingProgressBar');
                      }
                    },
                                  ),
                  ),
                ),

                ],
              ),
            ),
          )),
    );
  }

  Widget _buildListing(Map<String, dynamic> listingDetails)
  {
    return GestureDetector(
      onTap: ()
      {
        Navigator.push(context, MaterialPageRoute(builder: (context) => FullImageView(listingDetails: listingDetails)));
      },
      child: Container(
          color: Colors.grey,
          width: screenWidth,
          height: screenHeight - 450,
          child: PageView.builder(
            onPageChanged:  (page)
            {
              setState(() {
                _currentPageNotifier.value = page ;
              });
            },

            itemCount: listingDetails['imageInfoList'].length,
            itemBuilder: (context, index) {
              List<dynamic> imageInfo = listingDetails['imageInfoList'];
              String imageUrl = imageInfo[index]; // Correct the field name
              return buildImageWidget(imageUrl);
            },
          )
      ),
    );

  }

  Widget buildImageWidget(String imagePath) {
    return FittedBox(
      fit: BoxFit.cover,
      child: Image.network(
        // scale: addListingState.zoomLevel,
        imagePath,
      ),
    );
  }



  Widget circleIndicator()
  {
    return CirclePageIndicator(
      size: screenWidth/30,
      selectedSize: screenWidth/26,
      itemCount: widget.detailedListingsStore.listingInfo['imageInfoList'].length,
      currentPageNotifier: _currentPageNotifier,
    );
  }

  Widget fullImageView(context, Map<String, dynamic> listingDetails)
  {
    return Container(
        color: Colors.transparent,
        width: screenWidth,
        height: screenHeight,
        child: PageView.builder(
          onPageChanged: (page) {
            setState(() {
              _currentPageNotifier.value = page;
            });
          },
          itemCount: listingDetails['imageInfoList'].length,
          itemBuilder: (context, index) {
            Map<String, dynamic> imageInfo =
            listingDetails['imageInfoList'][index];
            String imageUrl = imageInfo['url']; // Correct the field name
            return buildImageWidget(imageUrl);
          },
        ));
  }
}

