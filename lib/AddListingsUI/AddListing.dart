import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ecomodation/Camera/camera.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ecomodation/Modelload.dart';
import 'AddListing_StateManage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ecomodation/Camera/image_data.dart';
import 'package:page_view_indicators/page_view_indicators.dart';



class AddListing extends StatefulWidget {
  final XFile? imagePath; // passing the image from the TakePicture.dart
  const AddListing({Key? key, this.imagePath}) : super(key: key); //Note: we are setting the default value for angle at 0.0 because we do not need to pas value of
  //other UI's where we are using Addlisting
  static List<ImageData> imagePaths = []; // To hold all the images inside this list.
  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> with AutomaticKeepAliveClientMixin<AddListing> {

  @override

  bool get wantKeepAlive => true; //getter function to keep the state of the widget same
  Model model = Model();
  XFile? image;
  int currentIndex = 0; //Pointer to keep track of the images when deleted
  int initialPage = 0;
  final PageController _pageController = PageController();
  final  _currentPageNotifier = ValueNotifier<int>(0);
  bool? isApartment = false;
  bool? isModelLoaded = false;
  late dynamic labels;
  List<double> probThreshold = [0.2]; //set the prob Threshold for the model to predict whether an uploaded image is related to apartment or non apartment

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 932); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }

  @override
  void initState() //initialize the list
  {
    super.initState();

    //model.loadModel(); //load the model

    final addListingState = Provider.of<AddListingState>(context, listen: false); //create instance of the addListingState here.
  //
    if (widget.imagePath != null) //if the list is not empty
    {
      updateList(widget.imagePath,
          addListingState.angle); //Update the list each time with the angle
    }


  }

  @override
  void dispose() {
    super.dispose();
    model.interpreter.close();
  }


  void updateList(XFile? image, double imageAngle) //add the images to the list here
  {
    setState(() {
      AddListing.imagePaths.add(ImageData(
          image!.path, imageAngle)); //adding the angle to each individual image
      initialPage = AddListing.imagePaths.length -1;
      verifyIfApartmentImage();
      if(_pageController.hasClients) {
        _pageController.jumpToPage(initialPage);
      }
    });

  }

  Future<void> addImageFromGallery() async {
    //Function to add the image from the gallery.

    final ImagePicker picker = ImagePicker(); //create instance for imagePicker

    try {
      image = await picker.pickImage(
          source: ImageSource.gallery); //get the image from the galleryq

      if(mounted) {
        final galleryImageAngle = Provider.of<AddListingState>(context,
            listen: false); //create separate instance from addListing class

        galleryImageAngle.angle =
        0.0; //reset the angle to zero here so it takes the angle of the original image chosen from the gallery

        updateList(image, galleryImageAngle.angle); //update the image and add to the list.
      }} catch (e) {
      //print(e);
    }
  }

  @override
  Widget build(BuildContext context) {

    super.build(context); //calling super.build here in order to use AutomaticKeepAliveClientMixin

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(top: 75),
                child: navigateBackButton()),
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Text('Add an Image', style: TextStyle(
                    fontSize: fontSize(context, screenWidth/11),
                    fontWeight: FontWeight.bold,
                  ),),
                )),
            SizedBox(height: screenHeight/15.5),
            Stack(
                children: [
                  Align(
                    alignment: Alignment(0,1),
                    child: buildImageViewer(),
                  ),
                  buildEditImage(), //calling the buildEditImage button
                ],
            ),

            SizedBox(height: screenHeight/46.6),
            circleIndicator(),

            addImageButton(), //call the addImage button here

            const Spacer(),
            Padding(
                padding:EdgeInsets.only(bottom: 20),
                child: nextPageButton()),
          ],
        ),
      ),
    );
  }

  /* Widget to view the Image in the PageViewBuilder*/
  Widget buildImageViewer() {

    if (AddListing.imagePaths.isEmpty) {
      return DottedBorder(
        color: Colors.grey,
        strokeWidth: 3,
        dashPattern: const [22, 22],
        child: Container(
          color: Color(0x5AD3D3D3),
          width: screenWidth - 13,
          height: screenHeight - 454,
          child: AddListing.imagePaths != null
              ? PageView.builder(

            controller: _pageController,
            itemCount: AddListing.imagePaths.length,
            itemBuilder: (context, index) {
              currentIndex = index;
              return buildImageWidget(AddListing.imagePaths[index].imagePath,
                  AddListing.imagePaths[index].rotationAngle);
            },
            onPageChanged: (page) {
              setState(() {
                initialPage = page;
                _currentPageNotifier.value = page;
              });
            },
          )
              : null,
        ),
      );
    }
    else
      {
        return Container(
          color: Color(0x5AD3D3D3),
          width: screenWidth,
          height: screenHeight - 454,
          child: AddListing.imagePaths != null
              ? PageView.builder(

            controller: _pageController,
            itemCount: AddListing.imagePaths.length,
            itemBuilder: (context, index) {
              currentIndex = index;
              return buildImageWidget(AddListing.imagePaths[index].imagePath,
                  AddListing.imagePaths[index].rotationAngle);
            },
            onPageChanged: (page) {
              setState(() {
                initialPage = page;
                _currentPageNotifier.value = page;
              });
            },
          )
              : null,
        );
      }
  }

  /*
   return DottedBorder(
      color: Colors.grey,
      strokeWidth: 3,
      dashPattern: const [22,22],
      child:
   */
  /* Widget to Edit the image */
  Widget buildEditImage() //Widget Icon to build the edit image icon
  {
    if (AddListing.imagePaths.isNotEmpty) {
      return Align(
        alignment: const Alignment(1, -0.8),
        child: IconButton(
          onPressed: () async {
            return deleteOrCancel(context);
          },
          icon: const Icon(Icons.edit, color: colorTheme, size: 30),
        ),
      );
    } else {
      return Container();
    }
  }

/* Widget to build the Image */
  Widget buildImageWidget(String imagePath, double rotationAngle) {
    return AspectRatio(
      aspectRatio: 16/9,
      child: FittedBox(
        fit: BoxFit.cover,
        child: Transform.rotate(
          angle: rotationAngle,
          child: Image.file(
            // scale: addListingState.zoomLevel,
            File(imagePath),
          ),
        ),
      ),
    );
  }

  Widget addImageButton() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: IconButton(
          onPressed: () {
            try {
              uploadOrTakeImage(context);
            } catch (e) {
            // print('Error $e');
            }
            //Draw the UI for the user to choose to either upload or take the image using device's camera
            // XFile? pickedFile = await ImagePicker().pickImage(
            //source: ImageSource.gallery);
          },

          icon:  Align(
              alignment: Alignment.center,
              child: Icon(Icons.add_circle, color: Colors.green, size: screenWidth/8)),
        ),
      ),
    );
  }

/* Widget to give the user option to pick the image either from the gallery or from the camera */

  Future uploadOrTakeImage(BuildContext context) //Widget to display the option to display and upload image

  {
    var boxHeight = screenHeight / 5; //Adjust the size
    var cameraIconSize = boxHeight / 2.9; //Adjust the size of the Icons
    var paddingCameraText = boxHeight - 150; //Padding for the Camera Icon
    var paddingGalleryText = boxHeight - 150; //Padding for the Gallery icon
    var textSize = cameraIconSize / 2.9; //Size for the text
    // var gapBetweenIcons = boxHeight;  //gap between two icons

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: Colors.white,
              height: boxHeight, //height of the container to each device

              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () async {
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
                    child: Row(
                      //Using a row Widget to place each icon in a row fashion
                      children: [
                        Align(
                          alignment: const Alignment(-1, 0),
                          //Align the icons to the corner
                          child: IconButton(
                              onPressed: null,
                              icon: Icon(Icons.camera_alt,
                                  size: cameraIconSize, color: Colors.black87)),
                        ),
                        SizedBox(width: screenWidth/16.5),
                        Padding(
                          padding: EdgeInsets.only(top: paddingCameraText, left: 6),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Camera',
                              style: TextStyle(
                                fontSize: textSize,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 15),
                Divider(thickness: 2, indent: screenWidth/4.9),
                  InkWell(
                    onTap: () async =>  addImageFromGallery(),
                    child: Row(
                        children: [
                      Align(
                        alignment: const Alignment(-1, 0),
                        child: IconButton(
                            onPressed: null,
                            icon: Icon(Icons.image_rounded,
                                size: cameraIconSize, color: Colors.black87)),
                      ),
                      SizedBox(width: screenWidth/13),
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
                  ),
                  SizedBox(height :10),
                  Divider(thickness: 2, indent: screenWidth/4.9),    ],

              ));

        });
  }

  /* Widget to make the delete or cancel popup */
  Future deleteOrCancel(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              content: Container(
                  width: screenWidth / 11,
                  height: screenHeight / 11,
                  color: Colors.white,
                  child: Center(
                    child: Column(
                      children: [
                        const Text('Do you want to delete this image?',
                            style: TextStyle(fontSize: 14)),
                         SizedBox(height: screenHeight/80),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Align(
                              alignment: const Alignment(-1, 2),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(
                                        context); //get out of the widget
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.green),
                                    fixedSize: MaterialStateProperty.all(
                                         Size(screenWidth/4.32, screenWidth/43.2)),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  )),
                            ),
                            const Spacer(),
                            Align(
                              alignment: const Alignment(1, 2),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      AddListing.imagePaths
                                          .remove(AddListing.imagePaths[currentIndex]);
                                      currentIndex = AddListing.imagePaths.length - 1;
                                      Navigator.pop(context);
                                    });
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.red),
                                    fixedSize: MaterialStateProperty.all(
                                      Size(screenWidth/4.32, screenWidth/43.2)),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )));
        });
  }

  Widget circleIndicator()
  {
    return CirclePageIndicator(
      size: screenWidth/30,
      selectedSize: screenWidth/26,
      itemCount: AddListing.imagePaths.length,
      currentPageNotifier: _currentPageNotifier,
    );
  }

/* Widget to build the "Next" button*/
  Widget nextPageButton() {
    final fontSizeNextButton = 19 * (screenHeight / 844);
    return ElevatedButton(
      onPressed: () async {
        if(AddListing.imagePaths.isNotEmpty ) //if the list is not empty, then navigate to adddescription
         {
        if(mounted)
        {
          Navigator.pushNamed(context, 'AddDescriptionPage');
        }
          }
        else {
          ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            duration: const Duration(seconds:2),
            backgroundColor: Colors.black,
            content:  Padding(
                padding:  EdgeInsets.only(left: screenWidth/5),
            child: Text("Please add an image!", style: TextStyle(
              color: Colors.white,
              fontSize: fontSize(context, 18),
            ),)),
            behavior: SnackBarBehavior.floating,
             margin: EdgeInsets.all(screenWidth/18),
             shape: const StadiumBorder(),
             action: SnackBarAction(
             label: '',
              onPressed: () {
          },
        ),
      ),
    );
        }


      },

      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        )),
        fixedSize: MaterialStateProperty.all(Size(screenWidth - 50, screenHeight/19)),
        backgroundColor: const MaterialStatePropertyAll(
            colorTheme), //set the color for the continue button
      ),
      child:  Text(
        'Next',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSizeNextButton,
        ),
      ),
    );
  }

  Future<void> verifyIfApartmentImage() async {
    for (var imageData in AddListing.imagePaths) {
      List<double> prob = await model.preprocessImage(imageData.imagePath);

      if (prob.first > probThreshold.first && mounted) {
        final snackBar = SnackBar(
          duration: const Duration(seconds: 3),
          backgroundColor: Colors.black,
          content: Padding(
            padding: EdgeInsets.only(left: screenWidth / 5),
            child: Text(
              "We have detected that the image is not apartment related. Please make sure the image uploaded is Apartment related. ",
              style: TextStyle(
                color: Colors.white,
                fontSize: fontSize(context, 18),
              ),
            ),
          ),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(screenWidth / 18),
          shape: const StadiumBorder(),
          action: SnackBarAction(
            label: '',
            onPressed: () {},
          ),
        );

        // Get the current ScaffoldMessenger
        final scaffoldMessenger = ScaffoldMessenger.of(context);

        // Show the snackbar
        scaffoldMessenger.showSnackBar(snackBar);
      }
    }
  }

  Widget navigateBackButton() {

    return Align(
      alignment: const Alignment(-1, -0.8),
      child: IconButton(
          onPressed: () {Navigator.pushNamed(context, 'HomeScreen');},
          icon: const Icon(Icons.arrow_back_rounded,
              size: 35, color: Colors.black)),
    );
  }
}
