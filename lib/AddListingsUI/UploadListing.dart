import 'package:ecomodation/Auth/auth_provider.dart';
import '../phoneLogin/LoginWithPhone.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'AddDescription.dart';
import '/AddListingsUI/AddListing.dart';
import 'package:ecomodation/PhoneLogin/OTPpage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ListingPrice.dart';
import 'dart:io';


class UploadListing {


  Future uploadListing(var documentId) async
  {
    DocumentReference userDocument = FirebaseFirestore.instance.collection(
        'userInfo').doc(documentId); //refer to the document ID.

    // Reference to the 'ListingInfo' collection within the user's document
    CollectionReference writeListingInfo = userDocument.collection(
        'ListingInfo'); //refer to the listing Info collection
    List<String> imageInfoList = [];

    for (String image in AddListing.allImages) {
      if (!image.contains('https')) {
        File imageFile = File(image); //Get the image path
        String imageName = basename(
            imageFile.path); //get the basename from the path
        String fileNameClean = imageName.split('.')[0];
        fileNameClean = fileNameClean.replaceAll(RegExp('[^a-zA-Z0-9 ]'), "");
        fileNameClean = fileNameClean.replaceAll(" ", "-");
        //Upload the image
        Reference storageReference = FirebaseStorage.instance.ref().child(
            'images/$imageName');
        await storageReference.putFile(imageFile); //wait for

        String imageUrl = await storageReference.getDownloadURL();

        imageInfoList.add(imageUrl);
      }
      else
        {
          imageInfoList.add(image);
        }
    }
    try {
      // Find the existing document for the user
      QuerySnapshot querySnapshot = await writeListingInfo.get();
      if (querySnapshot.docs.isNotEmpty) {
        // If document exists, update it
        DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
        await documentSnapshot.reference.update({
          'Title': AddDescription.titleController.text,
          'Description': AddDescription.descriptionController.text,
          'Price': ListingPrice.phoneText.text,
          'imageInfoList': imageInfoList,
          'Rented': false,
        });
      }
      else {
        // If document doesn't exist, create a new one
        await writeListingInfo.add({
          'Title': AddDescription.titleController.text,
          'Description': AddDescription.descriptionController.text,
          'Price': ListingPrice.phoneText.text,
          'imageInfoList': imageInfoList,
          'Rented': false,
        });
      }
    } catch (e) {
  // Handle error
  }

  }
    Future<bool> checkIfLocationIsUploaded() async {
      var checkLocation = await FirebaseFirestore.instance.collection(
          'userInfo').doc(
          loggedInWithGoogle ? googleLoginDocID : phoneLoginDocID).get();

      if (checkLocation.data()!.containsKey('Latitude') &&
          checkLocation.data()!.containsKey('Longitude')) {
        return true;
      }

      return false;
    }

    Future checkLoginMethod() async {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        if (loggedInWithGoogle ==
            true) { //if the user logged in via google, upload the listing to the google reg account
          await uploadListing(googleLoginDocID);
        } else if (loggedInWithPhone ==
            true) { //if the user logged in via phone, upload the listing to the phone reg account
          await uploadListing(phoneLoginDocID);
        } //else if (signInProvider == 'apple.com') {
        // User logged in using Apple Sign-In.
        // Handle accordingly.
      }
    }
  }

