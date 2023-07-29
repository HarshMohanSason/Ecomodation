import 'dart:io';
import 'package:camera/camera.dart';
import 'package:ecomodation/camera.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'homepage.dart';

class AddListing extends StatefulWidget {

  final XFile?firstImage; //using '?' to make sure firstImage accepts a null value
  final double angle, zoomedVal; //to get the angle at which the image is currently rotated to in the camera UI.
  List<String>? imagePaths = [];  // passing the list from the TakePicture.dart
  AddListing(
      { Key? key, this.firstImage, this.angle = 0.0, this.zoomedVal = 0.0, this.imagePaths}) : super(key: key); //Note: we are setting the default value for angle at 0.0 because we do not need to pas value of
  //other UI's where we are using Addlisting


  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> {


  @override
  Widget build(BuildContext context) {

   // var bottomPadding = screenHeight / 4.688;

    return WillPopScope(
      onWillPop: () async => false,

      child: Scaffold(
        body: Stack(
          children: [

            Align(
              alignment: const Alignment(1, -0.8),
              child: Ink(
                decoration: const ShapeDecoration(
                  color: colorTheme,
                  shape: CircleBorder(),
                ),
                child: const IconButton(
                  onPressed: null,
                  icon: Icon(Icons.edit, color: Colors.black, size: 30),
                ),
              ),
            ),

             Align(
              alignment: const Alignment(-1,-0.8),
              child: IconButton (
                  onPressed: () =>  Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScreen())),
                  icon: Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
              ),
            ),

            Column(

                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  const SizedBox(height: 100),

                  Container(
                      color: Colors.grey,
                      width: screenWidth,
                      height: screenHeight - 454,
                      child:  widget.imagePaths!= null ?
                        PageView.builder(
                        itemCount: widget.imagePaths?.length,
                        itemBuilder: (context, index) {
                          return buildImageWidget(widget.imagePaths![index]);
                        },
                      ) : null,
                  ),

                  const SizedBox(height: 10),
                  //Space between the container and the add image button
                  Align(
                    alignment: const Alignment(0, 1),
                    child: Ink(
                      decoration: const ShapeDecoration(
                        color: colorTheme,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        onPressed: () {
                          try {
                            uploadOrTakeImage(context);
                          } catch (e) {
                            print('Error $e');
                          }
                          //Draw the UI for the user to choose to either upload or take the image using device's camera
                          // XFile? pickedFile = await ImagePicker().pickImage(
                          //source: ImageSource.gallery);
                        },
                        icon: const Padding(
                          padding:  EdgeInsets.only(right: 8),
                          child: Icon(Icons.add,
                              color: Colors.black, size: 33),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 150),

                  ElevatedButton(
                      onPressed: null,
                      style: ButtonStyle(
                        fixedSize: MaterialStateProperty.all(const Size(180, 40)),
                        backgroundColor: const MaterialStatePropertyAll(
                            colorTheme), //set the color for the continue button
                      ),
                      child: const Text(
                        'continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ))
                ]),
          ],
        ),
      ),
    );
  }

  Widget buildImageWidget(String imagePath) {

    return SizedBox(
      child: Transform.rotate(
          angle: widget.angle,
          child: Image.file(
            File(imagePath),
            fit: BoxFit.cover,
          ),
      ),
    );
  }

  Future uploadOrTakeImage(
      BuildContext
          context) //Widget to display the option to display and upload image

  {
    var boxHeight = screenHeight / 5.62; //Adjust the size
    var cameraIconSize = boxHeight / 2.5; //Adjust the size of the Icons
    var paddingCameraText = boxHeight - 122; //Padding for the Camera Icon
    var paddingGalleryText = boxHeight - 115; //Padding for the Gallery icon
    var textSize = cameraIconSize / 2.5; //Size for the text
    // var gapBetweenIcons = boxHeight;  //gap between two icons

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: colorTheme,
              height: boxHeight, //height of the container to each device

              child: Column(
                //Column Widget to place each icon in a column fashion
                children: [
                  Row(
                    //Using a row Widget to place each icon in a row fashion
                    children: [
                      Align(
                        alignment: const Alignment(-1, 0),
                        //Align the icons to the corner
                        child: IconButton(
                            onPressed: () async {
                              try {
                                await availableCameras().then((value) =>
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (_) =>
                                                CameraUI(cameras: value))));
                              } catch (e) //Handle the case when no camera can be loaded
                              {
                                const Text(
                                    'Unable to load the camera from the device'
                                    //display an error on the screen
                                    ,
                                    style: TextStyle(
                                        color: Colors
                                            .red //Set the color of the text to red.
                                        ));
                              }
                            },
                            icon: Icon(Icons.camera_alt,
                                size: cameraIconSize, color: Colors.black87)),
                      ),
                      const SizedBox(width: 40),
                      Padding(
                        padding: EdgeInsets.only(top: paddingCameraText),
                        child: Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: textSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(children: [
                    Align(
                      alignment: const Alignment(-1, 0),
                      child: IconButton(
                          onPressed: null,
                          icon: Icon(Icons.image_rounded,
                              size: cameraIconSize, color: Colors.black87)),
                    ),
                    const SizedBox(width: 40),
                    Padding(
                      padding: EdgeInsets.only(top: paddingGalleryText),
                      child: Text(
                        'Gallery',
                        style: TextStyle(
                          fontSize: textSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ]),
                ],
              ));
        });
  }
}
