
import 'package:flutter/material.dart';
import 'package:page_view_indicators/circle_page_indicator.dart';
import '../main.dart';

class FullImageView extends StatefulWidget {

  final Map<String, dynamic> listingDetails;

  const FullImageView({Key? key, required this.listingDetails}) : super(key: key);

  @override
  State<FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends State<FullImageView> {

  final  _currentPageNotifier = ValueNotifier<int>(0);

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children : [
            Padding(
              padding: const EdgeInsets.only(top: 60, left: 10),
              child: Align(
                  alignment: Alignment.topLeft,
                  child: InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.cancel, size: screenWidth/8, color: colorTheme,))
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: screenHeight - 780),
              child: Container(
                color: Colors.transparent,
                width: screenWidth,
                height: screenHeight/2,
                child: PageView.builder(
                  onPageChanged:  (page)
                  {
                    setState(() {
                      _currentPageNotifier.value = page ;
                    });
                  },

                  itemCount: widget.listingDetails['imageInfoList'].length,
                  itemBuilder: (context, index) {
                    Map<String,
                        dynamic> imageInfo = widget.listingDetails['imageInfoList'][index];
                    String imageUrl = imageInfo['url']; // Correct the field name
                    return buildImageWidget(imageUrl);
                  },
                )
                      ),
            ),
            Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Center(child: circleIndicator())),
          ] ),
      ),
    );
    }


  Widget buildImageWidget(String imagePath) {
    return FittedBox(
      fit: BoxFit.contain,
      child: InteractiveViewer(  //Using Interactive viewer to make sure the image is zoomable
        minScale: 0.5,
        maxScale: 4,
        child: Image.network(
          // scale: addListingState.zoomLevel,
          imagePath,
        ),
      ),
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
