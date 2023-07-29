import 'dart:io';
import 'dart:math';
import 'package:ecomodation/AddListing.dart';
import 'camera.dart';
import 'CustomIcons/my_flutter_app_icons.dart' as custom_icons;
import 'package:camera/camera.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:cross_file/cross_file.dart';


class TakePicture extends StatefulWidget {

  XFile picture;

  TakePicture({Key? key, required this.picture}) : super(key: key);


  @override
  State<TakePicture> createState() => _TakePictureState();
}

class _TakePictureState extends State<TakePicture> {

  List<String> imagesList = []; //Store the images in this list, pass this to the addlisting constructor.

  late double angle = 0; //default value of angle to zero
  late double zoomLevel; //zoomed in value
  bool isZoomed = false;
  TransformationController scaleController = TransformationController();

  void calcAngle() async  //function to calculate the value of angle
  {
    double degrees = -90.0;  //set degrees to -90 because we need to rotate the image by that.
    setState(() {
      angle += degrees * pi / 180;  //convert to radians.
    });
  }

  void addImages() {
    setState(() {
      imagesList.add(widget.picture.path);
    });
 }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: takePictureUI(),  //call the takePictureUI here in the body
    );
  }

/*  Widget to take the picture of the apartment  */

  Widget takePictureUI() {
    return Stack(

      children: [

        Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              const Padding(
                padding: const EdgeInsets.only(top: 75),
                child: Center(
                  child: Text('Adjust and scale',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'MerriWeather',
                    ),),
                ),
              ),
              const SizedBox(height: 15),
              imageContainer(),
              Align(
                alignment: const Alignment(0, -0.5),
                child: IconButton(
                    onPressed: () {
                      calcAngle();
                    },
                    icon: const Icon(Icons.rotate_left, size: 40, color: Colors.black)),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),
                    IconButton(
                        alignment: Alignment(0, -1),
                        icon: Icon(custom_icons.MyFlutterApp.cancel_circled,
                            color: Colors.red, size: 65),
                        onPressed: () async =>
                        await availableCameras().then((value) => Navigator.push(
                            context, MaterialPageRoute(
                            builder: (_) => CameraUI(cameras: value))))
                    ),
                    const Spacer(flex: 2),
                    IconButton(
                        alignment: Alignment(0, -1),
                        icon: Icon(custom_icons.MyFlutterApp.ok_circled,
                            color: Colors.green, size: 65),

                        onPressed: ()
                        {
                          if(isZoomed == true)
                          {
                            addImages();
                            Navigator.push(context, MaterialPageRoute(
                                builder: (context) =>
                                    AddListing(firstImage: widget.picture,
                                      angle: angle,
                                      zoomedVal: zoomLevel, imagePaths: imagesList,)));
                          }

                          else
                            {
                              addImages();
                              Navigator.push(context, MaterialPageRoute(
                                  builder: (context) =>
                                      AddListing(firstImage: widget.picture,
                                        angle: angle, imagePaths: imagesList,)));
                            }
                        }
                    ),
                    const Spacer(flex: 4),
                  ]),
            ]),
      ],);
  }


  Widget imageContainer() {

    return InteractiveViewer(

    transformationController: scaleController,
      panEnabled: false,
      onInteractionUpdate: (details)
      {
        setState(() {
          zoomLevel = scaleController.value.getMaxScaleOnAxis();  // get the zoomed in value
          isZoomed = true;
        });
      },

      minScale: 1,
      maxScale: 4,
         child: SizedBox(
         width: screenWidth,
         height: screenHeight - 300,
           child: Transform.rotate(
           angle: angle,
             child: Image.file(
                File(widget.picture!.path),
                fit: BoxFit.contain,),
        ),
      ),
    );
  }

}
