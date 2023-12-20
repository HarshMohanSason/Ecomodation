
import 'package:ecomodation/Messaging/InitialMessage.dart';
import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:flutter/material.dart';
import 'package:ecomodation/main.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import 'DetailedListingsStore.dart';


class DetailedListingInfo extends StatefulWidget {

  final DetailedListingsStore detailedListingsStore;

  const DetailedListingInfo({Key? key, required this.detailedListingsStore}) : super(key: key);

  @override
  State<DetailedListingInfo> createState() => _DetailedListingInfoState();
}

class _DetailedListingInfoState extends State<DetailedListingInfo> {

  final MessageService _messageService = MessageService();
  final  _currentPageNotifier = ValueNotifier<int>(0);


  @override
  void initState() {

     super.initState();

  }


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async => false,
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
                      padding: const EdgeInsets.only(top: 60),
                      child: Align(
                        alignment: const Alignment(-1, 0),
                        child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: ButtonStyle(
                              fixedSize: MaterialStateProperty.all<Size>(Size(screenWidth/10,screenWidth/10)),
                              shape: MaterialStateProperty.all<OutlinedBorder>(const CircleBorder()),
                              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
                            ),
                            child: Icon(Icons.arrow_back_outlined,
                                size: screenWidth / 16, color: Colors.black,


                            )),
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

                  FutureBuilder<Widget>(
                    future: sendMessageButton(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Handle loading state
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        // Handle error state
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // Handle the completed state
                        return snapshot.data ?? const SizedBox(); // Returning an empty container if data is null
                      }
                    },
                  ),

                ],
              ),
            ),
          )),
    );
  }

  Widget _buildListing(Map<String, dynamic> listingDetails)
  {
    return Container(
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
          Map<String,
              dynamic> imageInfo = listingDetails['imageInfoList'][index];
          String imageUrl = imageInfo['url']; // Correct the field name
          double rotationAngle = imageInfo['rotationAngle'];
          return buildImageWidget(imageUrl, rotationAngle);
        },
      )
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

  Future<Widget> sendMessageButton() async {

     var isInitialMessageSent = await _messageService.checkInitialMessageSent(widget.detailedListingsStore);

     if(isInitialMessageSent == false) {
       return Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Align(
            alignment: const Alignment(0, 0.5),
            child: ElevatedButton(
              style: ButtonStyle(
                fixedSize: MaterialStateProperty.all(const Size(180, 40)),
                backgroundColor: const MaterialStatePropertyAll(
                    colorTheme), //set the color for the continue button
              ),
              onPressed: () async {
                {
                  var receiverId = await _messageService
                      .getReceiverID(widget.detailedListingsStore.listingInfo); //get the receiverID

                  if(mounted) {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => InitialMessageWidget(receiverID: receiverId, detailedListingsStore: widget.detailedListingsStore,)));
                  }
                }
              },

              child: Text(
                'Ask',
                style: TextStyle(
                  fontSize: 17 * (screenHeight / 932),
                  color: const Color(0xFFFFFFFF),
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
      );
     }
     else
       {
         return Padding(
             padding: const EdgeInsets.only(bottom: 35),
             child: Center(child: Text('Already contacted!', style: TextStyle(
               fontSize: screenWidth/20,
               fontWeight: FontWeight.bold,
             ))));
       }

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

}

