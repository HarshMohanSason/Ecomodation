import 'dart:io';
import 'package:ecomodation/AddListingsUI/AddListing.dart';
import 'package:provider/provider.dart';
import 'camera.dart';
import '../CustomIcons/my_flutter_app_icons.dart' as custom_icons;
import 'package:camera/camera.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';
import 'package:ecomodation/AddListingsUI/AddListing_StateManage.dart';



class TakePicture extends StatefulWidget {


  XFile picture;
  TakePicture({Key? key, required this.picture}) : super(key: key);


  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {


  late double zoomLevel; //zoomed in value
  bool isZoomed = false;  //to check the zoomed in value
  TransformationController scaleController = TransformationController();


  @override
  Widget build(BuildContext context) {

    final addListingState = Provider.of<AddListingState>(context);

    return Scaffold(
      body: takePictureUI(addListingState),  //call the takePictureUI here in the body
    );
  }

/*  Widget to take the picture of the apartment  */

  Widget takePictureUI(AddListingState addListingState) {

    return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Padding(
            padding: const EdgeInsets.only(top: 75),
            child: Center(
              child: Text('Adjust the image',
                style: TextStyle(
                  fontSize: screenWidth/13,
                  fontWeight: FontWeight.bold
                ),),
            ),
          ),

          const SizedBox(height: 5),

          imageContainer(addListingState),
          
          Align(
            alignment: Alignment.center,
            child: IconButton(
                onPressed: () {
                  addListingState.calcAngle();
                },
                icon: const Icon(Icons.rotate_left, size: 40, color: Colors.black)),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Spacer(flex: 3),
                InkWell(
                  onTap: () async {
                    await availableCameras().then((value) => Navigator.push(
                        context, MaterialPageRoute(
                        builder: (_) => CameraUI(cameras: value))));
                  },
                  child: const IconButton(
                      alignment: Alignment(0, -1),
                      icon: Icon(custom_icons.MyFlutterApp.cancel_circled,
                          color: Colors.red, size: 65),
                      onPressed: null,

                  ),
                ),

                const Spacer(flex: 2),

                InkWell(
                  onTap: () {
                        {
                        if(isZoomed == true)
                        {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        AddListing(imagePath: widget.picture)));
                        }
                        else
                        {
                        Navigator.push(context, MaterialPageRoute(builder: (context) =>
                        AddListing(imagePath: widget.picture)));
                        }
                        }
                        },
                  child: const IconButton(
                      alignment: Alignment(0, -1),
                      icon: Icon(custom_icons.MyFlutterApp.ok_circled,
                          color: Colors.green, size: 65),

                      onPressed: null,
                  ),
                ),
                const Spacer(flex: 4),
              ]),
        ]);
  }


  Widget imageContainer(AddListingState addListingState) {

    return InteractiveViewer(

    transformationController: scaleController,
      panEnabled: false,
      onInteractionUpdate: (details)
      {
          final zoomLevel = details.scale;// get the zoomed in value
          //print(zoomLevel);
          addListingState.updateZoomLevel(zoomLevel);
          isZoomed = true;
      },

      minScale: 1,
      maxScale: 4,
         child: SizedBox(
         width: screenWidth,
         height: screenHeight - 300,
           child: Transform.rotate(
           angle: addListingState.angle,
             child: Image.file(
                File(widget.picture.path),
                fit: BoxFit.contain,),
        ),
      ),
    );
  }

}
