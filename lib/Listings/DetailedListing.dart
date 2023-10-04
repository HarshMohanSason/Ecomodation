import 'package:ecomodation/Messaging/MessageService.dart';
import 'package:flutter/material.dart';
import 'package:ecomodation/main.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import '../Messaging/MessageWidget.dart';


class DetailedListingInfo extends StatefulWidget {

  Map<String, dynamic> listingDetails;

  DetailedListingInfo({Key? key, required this.listingDetails}) : super(key: key);

  @override
  State<DetailedListingInfo> createState() => _DetailedListingInfoState();
}

class _DetailedListingInfoState extends State<DetailedListingInfo> {

  final MessageService _messageService = MessageService();

  final  _currentPageNotifier = ValueNotifier<int>(0);

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
                children: [
                  Stack(children: [
                    _buildListing(widget.listingDetails),
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
                    alignment: Alignment(-0.9, 0),
                    child: Text(widget.listingDetails['Title'],
                        style: TextStyle(
                          fontSize: screenWidth / 13,
                        )),
                  ),
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment(-0.9, 0),
                    child: Text(widget.listingDetails['Price'],
                        style: TextStyle(
                          fontSize: screenWidth/13,
                          fontWeight: FontWeight.bold,
                        ) ),
                  ),

                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment(-0.9, 0),
                    child: Text('Description:' + ' ' +  widget.listingDetails['Description'],
                        style: TextStyle(
                          fontSize: screenWidth/25,
                        ) ),
                  ),

                  Spacer(),
                  sendMessageButton(),
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

  Widget sendMessageButton()
  {
      return Align(
        alignment: const Alignment(0, 0.9),
        child: SizedBox(
          height: screenHeight/7,
          width: screenWidth/7,
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: colorTheme,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(Icons.messenger, size: screenWidth/16, color: Colors.black,), onPressed: ()
            async {
              var receiverId = await _messageService.getrecieverID(widget.listingDetails);
              Navigator.push(context, MaterialPageRoute(builder: (context) => MessageDisplay(receiverID: receiverId)));
            }
            ),
          ),
        )
      );
    }

  Widget circleIndicator()
  {
    return CirclePageIndicator(
      size: screenWidth/30,
      selectedSize: screenWidth/26,
      itemCount: widget.listingDetails['imageInfoList'].length,
      currentPageNotifier: _currentPageNotifier,
    );
  }

}

