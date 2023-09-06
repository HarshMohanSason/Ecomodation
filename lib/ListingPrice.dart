import 'package:ecomodation/AddListing.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:ecomodation/image_data.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'AddDescription.dart';
import 'main.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

class ListingPrice extends StatefulWidget {
  const ListingPrice({Key? key}) : super(key: key);

  @override
  State<ListingPrice> createState() => _ListingPriceState();


}


class _ListingPriceState extends State<ListingPrice> with TickerProviderStateMixin{


  static final phoneText = TextEditingController(); //to control the text editing inside the textForm widget
  final priceForm = GlobalKey<FormState>(); //key to verify the form when submitted

  bool formValidated = false;
  bool isUploading = false;


  late AnimationController controller;

  @override
  void initState() {
    controller = AnimationController(
      /// [AnimationController]s can be created with `vsync: this` because of
      /// [TickerProviderStateMixin].
      vsync: this,
      duration: const Duration(seconds: 5),
    );
    controller.repeat(reverse: false);
    super.initState();
  }


  // Create a reference to the user's document in the 'userInfo' collection

  Future<void> verifyForm(BuildContext context) async {

    if(priceForm.currentState!.validate())
      {
        formValidated = true;
      }
    else
      {
        formValidated = false;
      }
  }

  double fontSize(BuildContext context, double baseFontSize) //Handle the FontSizes according to the respective screen Sizes
  {
    //Using the size of text on the Emulator as the baseFontSize.

    final fontSize = baseFontSize * (screenHeight / 844); //Note, we divide by 932 because it is the original base height of the logical pixels of the emulator screen

    return fontSize; //return the final fontSize
  }

  @override
  Widget build(BuildContext context)
  {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: listingPrice(context),
      ),
    );
  }

  Widget listingPrice(BuildContext context){

    return Padding(
      padding:  const EdgeInsets.only(top: 80),
      child: Column(

        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,

        children: [

          Align(
            alignment: const Alignment(-1,-0.8),
            child: IconButton (
                onPressed: () {
                  Navigator.pushNamed(context, 'AddDescriptionPage');
                },
                icon: const Icon(Icons.arrow_back_rounded, size: 35, color: Colors.black)
            ),
          ),

          Align(
            alignment: Alignment.center,
              child: Text('Price',
                style: TextStyle(
                  fontSize: fontSize(context, 32),
                  fontWeight: FontWeight.bold,
                )
                ,)),

          const SizedBox(height: 20),

          Align(
              alignment: Alignment.center,
              child: addPrice(context)),

          Expanded(child:
          Align(
              alignment: Alignment(0,0.87),
              child: uploadButton(context))),
        ],
      ),
    );
  }

  Widget addPrice(BuildContext context){

    return SizedBox(
      width: screenWidth-70,
      child: Form(
        key: priceForm,
        child: TextFormField(
          cursorColor: colorTheme,
          cursorWidth: 4,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          controller: phoneText,
          cursorHeight: fontSize(context, 55),
          maxLines: 1,
         inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(7), RupeeInputFormatter()],
          style: TextStyle(fontSize: fontSize(context, 55), fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: '\u20B9', //get the rupee symbol
            hintStyle:  TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: fontSize(context, 60),
            ),

            border: OutlineInputBorder(
              borderSide: const BorderSide(width: 2.0),
              borderRadius: BorderRadius.circular(5),
            ),
          ),

          validator: (value)
          {
            var price = value;

            if(price!.isEmpty)
              {
                return 'Price cannot be empty';
              }
            return null;
          },
        ),
      ),
    );
  }

  Widget uploadButton(BuildContext context)

  {
    DocumentReference userDocument = FirebaseFirestore.instance.collection('userInfo').doc(documentIDPhoneLogin); //refer to the document ID.

     // Reference to the 'ListingInfo' collection within the user's document
    CollectionReference writeListingInfo = userDocument.collection('ListingInfo');  //refer to the listing Info collection

    return  ElevatedButton(

      onPressed: () async
      {
       await verifyForm(context);  //make sure the form submitted is correct

       if(formValidated == true) {
         showDialog(
           context: context,
           barrierDismissible: false, // Prevent the user from dismissing the dialog
           builder: (BuildContext context) {
             return Center(
               child: CircularProgressIndicator(
                 color: colorTheme,
                 value: controller.value,
               ),
             );
           },
         );
         List<Map<String, dynamic>> imageInfoList = []; // Upload the info.

         for (ImageData imageData in AddListing.imagePaths) {
           File imageFile = File(imageData.imagePath); //Get the image path
           String imageName = basename(imageFile.path); //get the basename from the path

           //Upload the image
           Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
           UploadTask uploadTask = storageReference.putFile(imageFile);

           await uploadTask.whenComplete(() async {
             String imageUrl = await storageReference.getDownloadURL();

             imageInfoList.add({
               'url': imageUrl,
               'rotationAngle': imageData.rotationAngle,
             });
           });
         }


         try {
           await writeListingInfo.add({
             'Title': AddDescription.titleController.text,
             'Description': AddDescription.descriptionController.text,
             'Price': phoneText.text,
             'imageInfoList': imageInfoList
           });
         }
         catch (e) {
           // print(e);
         }


         AddListing.imagePaths.clear(); //clear the imagePaths list
         AddDescription.descriptionController.clear(); //clear the description text from the description box
         AddDescription.titleController.clear(); //clear the title text from the title box
         phoneText.clear(); //clear the phone price from the textbox

         Navigator.pushNamed(context, 'HomeScreen'); //Navigate back to the home screen once the listing has been uploaded to the database

       }
      },
      style: ButtonStyle(
        shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),)),
        fixedSize: MaterialStateProperty.all(Size(screenWidth - 10, screenHeight/38)),
        backgroundColor: const MaterialStatePropertyAll(
            colorTheme), //set the color for the continue button
      ),

      child:  Text(
        'Upload',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: fontSize(context, 18),
        ),
      ),
    );
  }
}

/* Separate class to add the rupee symbol whenever the user enters any amount in the TextForm field. */

class RupeeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isNotEmpty) {
      return TextEditingValue(
        text: '\u20B9${newValue.text}',
        selection: TextSelection.collapsed(offset: newValue.selection.end + 1),
      );
    }
    return newValue;
  }
}
