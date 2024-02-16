
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:ecomodation/Camera/camera.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';


class AddListing extends StatefulWidget {

  final XFile? cameraImage; // passing the image from the camera.dart;
  const AddListing({Key? key, this.cameraImage}) : super(key: key);
  static List<String> allImages = []; // To hold all the images inside this list.

  PageController get _getPageController => PageController();
  ValueNotifier get _currentPageNotifier => ValueNotifier<int>(0);

  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> with TickerProviderStateMixin {

  final  _pageController = const AddListing()._getPageController;
  final _currentPageNotifier = const AddListing()._currentPageNotifier;

  int currentIndex = 0; //Pointer to keep track of the images when deleted
  int initialPage = 0;
  bool? isApartment = false;

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

  }

  @override

  void dispose()
  {
    super.dispose();
    _currentPageNotifier.dispose();
    _pageController.dispose();
  }

  void updateList(XFile? image) //add the images to the list here
  {
    setState(() {
      AddListing.allImages.add(image!.path); //adding the angle to each individual image
      initialPage = AddListing.allImages.length - 1;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(initialPage);
      }
    });
  }

  Future<void> addImageFromGallery() async {

    //Function to add the image from the gallery.

    final ImagePicker picker = ImagePicker(); //create instance for imagePicker
    try {
    var image = await picker.pickMultiImage(); //get the image from the gallery
    setState(() {
      AddListing.allImages = image.map((e) => e.path).toList();
    });

    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    
    return Column(

        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 15.0),
                child: Text('Add Your Property', style: TextStyle(
                  fontSize: fontSize(context, screenWidth / 12),
                  fontWeight: FontWeight.bold,
                ),),
              )),
          SizedBox(height: screenHeight / 15.5),
          Stack(
            children: [
              Align(
                alignment: Alignment.center,
                child: buildImageViewer(),
              ),
              buildEditImage(), //calling the buildEditImage button
            ],
          ),

          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: addImageButton()), //call the addImage button here
        ]
    );
  }

  /* Widget to view the Image in the PageViewBuilder*/
 Widget buildImageViewer() {
    if (AddListing.allImages.isEmpty) {
      return DottedBorder(
        color: Colors.grey,
        strokeWidth: 3,
        dashPattern: const [22, 22],
        child: Container(
          color: const Color(0x5AD3D3D3),
            width: screenWidth - 15,
            height: screenHeight - 450,
          child:  PageView.builder(
            controller: _pageController,
            itemCount: AddListing.allImages.length,
            itemBuilder: (context, index) {
              currentIndex = index;
              return buildImageWidget(AddListing.allImages[index]);
            },
            onPageChanged: (page) {
              setState(() {
                initialPage = page;
                _currentPageNotifier.value = page;
              });
            },
          )
        ),
      );
    }
    else {
      return Container(
        width: screenWidth,
        height: screenHeight - 450,
        color: const Color(0x5AD3D3D3),
        child: PageView.builder(
          controller: _pageController,
          itemCount: AddListing.allImages.length,
          itemBuilder: (context, index) {
            currentIndex = index;
            return buildImageWidget(AddListing.allImages[index],
            );
          },
          onPageChanged: (page) {
            setState(() {
              initialPage = page;
              _currentPageNotifier.value = page;
            });
          },
        )
      );
    }
  }


  Widget buildEditImage() //Widget Icon to build the edit image icon
  {
    if (AddListing.allImages.isNotEmpty) {
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
  Widget buildImageWidget(String imagePath) {
    if (imagePath.contains('https')) {
      return FittedBox(
        fit: BoxFit.contain,
        child: Image.network(
          // scale: addListingState.zoomLevel,
            imagePath
        ),
      );
    }
    else {
      return FittedBox(
        fit: BoxFit.contain,
        child: Image.file(
          // scale: addListingState.zoomLevel,
          File(imagePath),
        ),
      );
    }
  }

  Widget addImageButton() {
    return IconButton(
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

      icon: Icon(Icons.add_circle, color: Colors.black, size: screenWidth / 8),
    );
  }

/* Widget to give the user option to pick the image either from the gallery or from the camera */

  Future uploadOrTakeImage(BuildContext context) //Widget to display the option to display and upload image

  {
    var boxHeight = screenHeight / 5; //Adjust the size
    var cameraIconSize = boxHeight / 2.9; //Adjust the size of the Icons
    var textSize = cameraIconSize / 2.9; //Size for the text
    // var gapBetweenIcons = boxHeight;  //gap between two icons

    return showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return Container(
              color: Colors.white,
              height: screenHeight, //height of the container to each device
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
                                MaterialPageRoute(builder: (_) =>
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
                    child: Padding(
                      padding: const EdgeInsets.only(top: 5),
                      child: Row(
                        //Using a row Widget to place each icon in a row fashion
                        children: [
                          IconButton(
                              onPressed: null,
                              icon: Icon(Icons.camera_alt,
                                  size: cameraIconSize, color: Colors.black87)),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
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
                    ),
                  ),
                  Divider(thickness: 2, indent: screenWidth /30),
                  InkWell(
                    onTap: () async => addImageFromGallery(),
                    child: Row(
                        children: [
                          IconButton(
                              onPressed: null,
                              icon: Icon(Icons.image_rounded,
                                  size: cameraIconSize,
                                  color: Colors.black87)),
                          Padding(
                            padding: const EdgeInsets.only(left: 5),
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
                  Divider(thickness: 2, indent: screenWidth / 30),
                ],
              ));
        });
  }

  /* Widget to make the delete or cancel popup */
  Future deleteOrCancel(BuildContext context) {

    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.white,
              content: SizedBox(
                height: screenHeight/9,
                child: Center(
                  child: Column(
                    children: [
                  const Text('Do you want to delete this image?',
                      style:  TextStyle(
                      fontSize: 13),
                       ),
                      Padding(
                        padding: const EdgeInsets.only(top: 23),
                        child: Row(
                          children: [
                            Align(
                              alignment: const Alignment(-1, 2),
                              child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pop(context); //get out of the widget
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.grey),
                                    fixedSize: MaterialStateProperty.all(
                                        Size(screenWidth / 4.32,
                                            screenWidth / 43.2)),
                                  ),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )),
                            ),
                            const Spacer(),
                            Align(
                              alignment: const Alignment(1, 2),
                              child: ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      if(currentIndex == 0 && AddListing.allImages.length == 1)
                                        {
                                          AddListing.allImages.removeAt(currentIndex);
                                          currentIndex = 0;
                                          Navigator.pop(context);
                                        }
                                      else if(currentIndex == 0 && AddListing.allImages.length > 1)
                                        {
                                          AddListing.allImages.removeAt(currentIndex);
                                          currentIndex += 1;
                                          Navigator.pop(context);
                                        }
                                      else {
                                        AddListing.allImages.removeAt(currentIndex);
                                        currentIndex = AddListing.allImages.length - 1;
                                        Navigator.pop(context);
                                      }});
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                    MaterialStateProperty.all(Colors.red),
                                    fixedSize: MaterialStateProperty.all(
                                        Size(screenWidth / 4.32,
                                            screenWidth / 43.2)),
                                  ),
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  )),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

}
