
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'AddDescription.dart';
import '/AddListingsUI/AddListing.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'ListingPrice.dart';
import 'dart:io';

class UploadListing {

  DocumentReference userDocument = FirebaseFirestore.instance.collection('userInfo').doc(FirebaseAuth.instance.currentUser!.uid); //refer to the document ID.

  List<String> imageInfoList = []; //List for the images

  Future uploadTheListing() async {

    for (String image in AddListing.allImages) {
      if (!image.contains('https')) {

        File imageFile = File(image); //Get the image path
        String imageName = basename(imageFile.path); //get the basename from the path
        Reference storageReference = FirebaseStorage.instance.ref().child('images/$imageName');
        await storageReference.putFile(imageFile); //upload the image
        String imageUrl = await storageReference.getDownloadURL(); //get the Download Url for the image
        imageInfoList.add(imageUrl); //add the image to the list

      } else {
        imageInfoList.add(image);
      }
    }
    await uploadListingInfo();

  }

  Future uploadListingInfo() async {
    try {
      CollectionReference writeListingInfo = userDocument.collection('ListingInfo');
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
      } else {
        // If document doesn't exist, create a new one
        await writeListingInfo.add({
          'Title': AddDescription.titleController.text,
          'Description': AddDescription.descriptionController.text,
          'Price': ListingPrice.phoneText.text,
          'imageInfoList': imageInfoList,
          'Rented': false,
        });
      }
    }
    catch (e) {

      return e.toString();
    }
  }

  Future<bool> checkIfLocationIsUploaded() async {
    var checkLocation = await FirebaseFirestore.instance
        .collection('userInfo')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (checkLocation.data()!.containsKey('Latitude') &&
        checkLocation.data()!.containsKey('Longitude')) {
      return true;
    }
    return false;
  }

}
