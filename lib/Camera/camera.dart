
import 'dart:ui';
import 'package:camera/camera.dart';
import 'package:ecomodation/AddListingsUI/AddListing.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:croppy/croppy.dart';
import 'package:path_provider/path_provider.dart';


class CameraUI extends StatefulWidget {

  final List<CameraDescription>? cameras; //list to get the available cameras when the camera icon is pressed

  const CameraUI({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraUI> createState() => _CameraUIState();
}

class _CameraUIState extends State<CameraUI> {

  final AddListing _addListing = const AddListing();
  late CameraController _cameraController; //controller for the device camera
  bool isPictureTaken = false;
  late XFile pictureTaken;
  late CameraDescription _currentCamera = widget.cameras![0];

   //Create a type future function to initialize the camera using the camera controller
  Future initCamera(CameraDescription cameraDescription) async {
    //Initialize the selected camera

    _cameraController = CameraController(cameraDescription, ResolutionPreset.high, imageFormatGroup: ImageFormatGroup.bgra8888); //Create a camera Controller

    try {
      await _cameraController.initialize().then((_) {

        if (mounted) {
          setState(() {

          });
        }

      });

    } on CameraException catch (e) {
      debugPrint('Camera error $e');
    }

    await  _cameraController.lockCaptureOrientation(DeviceOrientation.portraitUp);

  }

  Future<XFile?> croppedImageToXFile(CropImageResult? image) async
  {
    try {
      if (image == null) {
        return null;
      }

      var imageData = await image.uiImage.toByteData(
          format: ImageByteFormat.png);

      if (imageData != null)
        {
      var unit8val = imageData.buffer.asUint8List();
      var tempDir = await getTemporaryDirectory();
      var timestamp = DateTime.now().millisecondsSinceEpoch;
      var filePath = "${tempDir.path}/temp_croppedImage_$timestamp.png";

      // Delete existing file if it exists
      if (await File(filePath).exists()) {
        await File(filePath).delete();
      }
      File file = await File(filePath).create();
      file.writeAsBytesSync(unit8val);
      return XFile(file.path);
    }
    }
    catch(e)
    {
      rethrow;
    }
     return null;
  }

  @override
  void initState() {
    super.initState();
    // initialize the rear camera
    initCamera(_currentCamera); //initialize the first camera from the list. Default camera is the rear camera
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: cameraPortrait(context),  //call the camera_portrait widget to build the camera.

        //   Expanded(child: bottomIcons(context)),
      ),
    );
  }



  Widget bottomIcons(BuildContext context)
  {

    //   var sizeOfTakePicButton = screenWidth / 6.5; //Adjust the size of the picture button according to the screenWidth\
    //  var sizeOfAddPhotoButton = screenWidth / 13; //Adjust the padding of the addphotoButton according to each screen
    return  const Row( // Use a row Widget to handle upload from album icon and take picture
      mainAxisAlignment: MainAxisAlignment.center,
      //Align everything in center
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Spacer(),
      ],
    );
  }


  Widget cameraPortrait(BuildContext context) {
    return Column(

      children: [
        SizedBox(
            width: screenWidth,
            height: screenHeight - 150,
            child: Center(child: CameraPreview(_cameraController))), // Show the camera preview

        Padding(
          padding: const EdgeInsets.only(top: 30),
          child: Row(

            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,

            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back, color: Colors.white, size: 30),
                ),
              ),
            const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: InkWell(
                  onTap: () async {
                    pictureTaken = await _cameraController.takePicture();

                    setState(() {
                      isPictureTaken = true;
                      Transform.rotate(
                          angle: 0,
                        child: Image.file(File(pictureTaken.path)),
                      );
                    });
                    if(isPictureTaken && mounted) //if the picture is taken, navigate to the takepicture UI
                        {
                          //print(Transformation.values);
                      try {
                        Future<CropImageResult?> croppedImage = showCupertinoImageCropper(
                          context,
                          imageProvider: FileImage(File(pictureTaken.path)
                          ),
                        );

                       XFile? finalImage = await croppedImage.then((value) => croppedImageToXFile(value));

                        if (finalImage != null && mounted) {
                        {
                          setState(() {
                            AddListing.allImages.add(finalImage.path);
                            Navigator.pushNamed(context, 'ListingProgressBar');
                          });
                        }
                        }
                        else {
                        //  print('Error: finalImage is null');
                        }
                      }
                      catch (e) {
                        //print('Error: $e');
                      }
                    }
                  },
                  child: const Icon(Icons.circle_sharp, color: Colors.white, size: 80),
                ),
              ),
            const  Spacer(),
              Align(
                alignment: Alignment.bottomRight,
                child: IconButton(
                  onPressed: ()
                  {
                    setState(() {
                      if (_currentCamera == widget.cameras![0]) {  //if the rear camera is selected

                        _currentCamera = widget.cameras![1]; //select the front camera
                      }
                      else{
                        _currentCamera = widget.cameras![0];  //else select the rear camera
                      }
                      initCamera(_currentCamera); //initialize the camera
                    });
                  },

                  icon: const  Icon(Icons.cameraswitch, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}