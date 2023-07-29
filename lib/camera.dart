import 'package:camera/camera.dart';
import 'package:ecomodation/AddListing.dart';
import 'package:ecomodation/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'TakePicture.dart';

class CameraUI extends StatefulWidget {

  final List<CameraDescription>? cameras; //list to get the available cameras when the camera icon is pressed

  const CameraUI({Key? key, required this.cameras}) : super(key: key);

  @override
  State<CameraUI> createState() => _CameraUIState();

}

class _CameraUIState extends State<CameraUI> {

  late CameraController _cameraController; //controller for the device camera
  bool portrait = false;
  bool isPictureTaken = false;
  late XFile pictureTaken;
  late CameraDescription _currentCamera = widget.cameras![0];

//Create a type future function to initialize the camera using the camera controller
  Future initCamera(CameraDescription cameraDescription) async {
    //Initialize the selected camera

    _cameraController = CameraController(cameraDescription, ResolutionPreset.high); //Create a camera Controller

    await SystemChrome.setPreferredOrientations(
        [ DeviceOrientation.portraitUp,
          DeviceOrientation.landscapeLeft,   //Initialize the setPrefferedOrientations
        ]
    );


    try {
      await _cameraController.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {
          portrait = true;
        });
      });
    } on CameraException catch (e) {
      debugPrint('Camera error $e');
    }
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


    return Scaffold(
      backgroundColor: Colors.black,
      body: cameraPortrait(context),  //call the camera_portrait widget to build the camera.

        //   Expanded(child: bottomIcons(context)),
    );
  }



  Widget bottomIcons(BuildContext context)

  {

    var sizeOfTakePicButton = screenWidth / 6.5; //Adjust the size of the picture button according to the screenWidth\
    var sizeOfAddPhotoButton = screenWidth / 13; //Adjust the padding of the addphotoButton according to each screen

    return   Row( // Use a row Widget to handle upload from album icon and take picture
      mainAxisAlignment: MainAxisAlignment.center,
      //Align everytbhing in center
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
       const Spacer(flex:21),
      ],
    );
  }


  //Initialize the camera in a different widget....

  Widget cameraPortrait(BuildContext context) {

   var boxheight = screenHeight/13;    // leng

    return Column(
      children: [

        SizedBox(
            width: screenWidth,
            height: screenHeight - 130, //size for the camera.

            child: CameraPreview(_cameraController)), // Show the camera preview

           Expanded(
             child: Row(

               mainAxisAlignment: MainAxisAlignment.center,
               crossAxisAlignment: CrossAxisAlignment.center,
               children: [
                 const Spacer(),
                 Align(
                   alignment: const Alignment(-1,-0.3),
                   child: IconButton(
                     onPressed: () {
                       Navigator.push(context, MaterialPageRoute(builder: (context) => AddListing()));
                     },
                     icon: Icon(Icons.arrow_back, color: Colors.white, size: 30),
                   ),
                 ),
                 const Spacer(flex: 4),
                 Align(
                   alignment: const Alignment(0,-0.7),
                   child: IconButton(
                    onPressed: () async {
                      pictureTaken = await _cameraController.takePicture();
                      setState(() {
                        isPictureTaken = true;
                      });
                      if(isPictureTaken) //if the picture is taken, navigate to the takepicture UI
                        {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => TakePicture(picture: pictureTaken)));
                        }
                    },
                    icon: Icon(Icons.circle_outlined, color: Colors.white, size: 80),
          ),
                 ),
                const Spacer(flex: 7),
                 Align(
                   alignment: const Alignment(0,-0.3),
                   child: IconButton(
                     onPressed: () {

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

                     icon: Icon(Icons.cameraswitch, color: Colors.white, size: 30),
                   ),
                 ),

               ],
             ),
           ),

      ],
    );
  }

}

