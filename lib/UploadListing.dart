import 'package:ecomodation/Auth/auth_provider.dart';
import 'package:ecomodation/LoginWithPhone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'AddDescription.dart';
import 'AddListing.dart';
import 'OTPpage.dart';
import 'image_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ListingPrice.dart';
import 'dart:io';

class UploadListing{

  Future uploadListing(var documentId) async{

    DocumentReference userDocument = FirebaseFirestore.instance.collection('userInfo').doc(documentId); //refer to the document ID.

    // Reference to the 'ListingInfo' collection within the user's document
    CollectionReference writeListingInfo = userDocument.collection('ListingInfo');  //refer to the listing Info collection
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
        'Price': ListingPrice.phoneText.text,
        'imageInfoList': imageInfoList
      });
    }
    catch (e) {
      // print(e);
    }

    AddListing.imagePaths.clear(); //clear the imagePaths list
    AddDescription.descriptionController.clear(); //clear the description text from the description box
    AddDescription.titleController.clear(); //clear the title text from the title box
    ListingPrice.phoneText.clear(); //clear the phone price from the textbox
  }


  Future checkLoginMethod() async {

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {

      if (loggedinWithGoogle == true) { //if the user logged in via google, upload the listing to the google reg account
      await uploadListing(googleLoginDocID);

      } else if (loggedInWithPhone == true) { //if the user logged in via phone, upload the listing to the phone reg account
       await uploadListing(documentIDPhoneLogin);

      } //else if (signInProvider == 'apple.com') {
        // User logged in using Apple Sign-In.
        // Handle accordingly.
      }
    }
}
