import 'dart:io';
import 'package:camera/camera.dart';
import 'package:ecomodation/camera.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'AddListing_StateManage.dart';
import 'homepage.dart';
import 'package:image_picker/image_picker.dart';
import 'image_data.dart';


class AddListing extends StatefulWidget{

  final XFile? imagePath;  // passing the list from the TakePicture.dart
  const AddListing({ Key? key, this.imagePath}) : super(key: key); //Note: we are setting the default value for angle at 0.0 because we do not need to pas value of
  //other UI's where we are using Addlisting

  @override
  State<AddListing> createState() => _AddListingState();
}

class _AddListingState extends State<AddListing> with AutomaticKeepAliveClientMixin<AddListing>{


  @override
  bool get wantKeepAlive => true; //getter function to keep the state of the widget same

  static List<ImageData> imagePaths = []; // To hold all the images inside this list.
  XFile? image; //
  int currentIndex = 0; //Pointer to keep track of the images when deleted


  @override
  void initState()  //initialize the list
  {
    super.initState();

    final addListingState = Provider.of<AddListingState>(context, listen: false); //create instance of the addListingState here.

    if (widget.imagePath != null)  //if the list is not empty
    {
      updateList(widget.imagePath, addListingState.angle); //Update the list each time with the angle
    }

  }

  void updateList(XFile? image, double imageAngle)     //add the images to the list here
 {
   setState(()
   {
     imagePaths.add(ImageData(image!.path, imageAngle));  //adding the angle to each individual image
   });

 }

 Future<void> addImageFromGallery() async {  //Function to add the image from the gallery.

   final ImagePicker picker = ImagePicker(); //create instance for imagePicker

   try
   {
     image = await picker.pickImage(source: ImageSource.gallery); //get the image from the galleryq

     final  galleryImageAngle = Provider.of<AddListingState>(context, listen: false); //create separate instance from addListing class

     galleryImageAngle.angle = 0.0; //reset the angle to zero here so it takes the angle of the original image chosen from the gallery

     updateList(image, galleryImageAngle.angle); //update the image and add to the list.
   }

   catch(e)
   {
     //print(e);
   }
 }

  @override
  Widget build(BuildContext context) {

    super.build(context); //calling super.build here in order to use AutomaticKeepAliveClientMixin

    return WillPopScope(

      onWillPop: () async => false,

      child: Scaffold(

        body: Stack(
          children: [

            buildEditImage(), //calling the buildEditImage button

             Align(
              alignment: const Alignment(-1,-0.8),
              child: IconButton (
                  onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainScreen()));
                  },
                  icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
              ),
            ),


            Column(

                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,

                children: [

                  const SizedBox(height: 100),

                  buildImageViewer(),

                  const SizedBox(height: 10),
                  //Space between the container and the add image button
                  addImageButton(), //call the addImage button here

                  const SizedBox(height: 150),

                  nextPageButton(), //call the next Pagebutton here
                ]),
          ],
        ),
      ),
    );
  }



  /* Widget to view the Image in the PageViewBuilder*/
  Widget buildImageViewer()
  {
    return Container(
      color: Colors.grey,
      width: screenWidth,
      height: screenHeight - 454,
      child:  imagePaths != null ?
      PageView.builder(
        controller: null,
        itemCount: imagePaths.length,
        itemBuilder: (context, index) {
          currentIndex = index;
          return buildImageWidget(imagePaths[index].imagePath, imagePaths[index].rotationAngle);
        },
      ) : null,
    );
  }

 /* Widget to Edit the image */
  Widget buildEditImage() //Widget Icon to build the edit image icon
  {
    if (imagePaths.isNotEmpty) {
      return Align(
        alignment: const Alignment(1, -0.8),
        child: Ink(
          decoration: const ShapeDecoration(
            color: colorTheme,
            shape: CircleBorder(),
          ),
          child: IconButton(
            onPressed: () async
            {
                return deleteOrCancel(context);
            },
            icon: const Icon(Icons.edit, color: Colors.black, size: 30),
          ),
        ),
      );
    }
    else
      {
        return Container();
      }
  }


/* Widget to build the Image */
  Widget buildImageWidget(String imagePath, double rotationAngle) {

    return FittedBox(
      fit: BoxFit.cover,
      child: Transform.rotate(
        angle: rotationAngle,
        child: Image.file(
         // scale: addListingState.zoomLevel,
          File(imagePath),
        ),
      ),
    );

  }

 Widget addImageButton()
 {
  return Align(
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
   );

 }
/* Widget to give the user option to pick the image either from the gallery or from the camera */

  Future uploadOrTakeImage(BuildContext context) //Widget to display the option to display and upload image

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
                          onPressed: () async => addImageFromGallery(),
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


  /* Widget to make the delete or cancel popup */
  Future deleteOrCancel(BuildContext context)
  {
    return showDialog(
        context: context,
        builder: (BuildContext context)
    {
      return AlertDialog(
        content: Container(width: screenWidth/11,
        height:screenHeight/11,
        color: Colors.white,

        child: Center(
          child: Column(
            children: [
              const Text('Do you want to delete this image?',
                  style: TextStyle(
                  fontSize: 14)),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: const Alignment(-1,2),
                    child: ElevatedButton(
                        onPressed: ()
                        {
                          Navigator.pop(context); //get out of the widget
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(Colors.green),
                          fixedSize: MaterialStateProperty.all(const Size(100, 10)),
                        ),
                        child: const Text('Cancel', style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),)),
                  ),
                  const Spacer(),
                  Align(
                    alignment: const Alignment(1,2),
                    child: ElevatedButton(
                        onPressed: (){

                        setState(() {
                          imagePaths.remove(imagePaths[currentIndex]);
                          currentIndex = imagePaths.length - 1;
                          Navigator.pop(context);
                        });
                    },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.red),
                        fixedSize: MaterialStateProperty.all(const Size(100, 10)),
                      ),
                        child: const Text('Delete', style: TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),)
                    ),
                  ),
                ],
              ),
            ],
          ),
        ))
      );
    }
    );
  }

/* Widget to build the "Next" button*/
  Widget nextPageButton(){

    return   ElevatedButton(
      onPressed: null,
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),)),
        fixedSize: MaterialStateProperty.all(Size(screenWidth - 10, 40)),
        backgroundColor: const MaterialStatePropertyAll(
            colorTheme), //set the color for the continue button
      ),
      child: const Text(
        'Next',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
    );

  }


}
