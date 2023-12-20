import 'package:ecomodation/OTPpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_checkifloggedin.dart';

var googleLoginDocID = '';
var googleUserName = ' ';

bool loggedInWithGoogle = false;

class Authentication  extends ChangeNotifier{


  final writeUserInfo = FirebaseFirestore.instance.collection(
      'userInfo'); //refer to the collection userInfo
  final readUserInfo = FirebaseFirestore.instance.collection(
      'userInfo'); //refer to read the data

  //create an instance to write data to firebase
  static Future <FirebaseApp> initializeFirebase() async //create a async function
      {
    FirebaseApp firebaseApp = await Firebase
        .initializeApp(); // Use the await keyword to wait for initialization to complete

    return firebaseApp; //return the firebaseApp when initialized
  }


  //Function to implement signInWith Google;
  signInWithGoogle() async {

    try {
      final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();
      if (gUser != null) {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        final userSnapshot = await FirebaseFirestore.instance.collection('userInfo') //get a snapshot of collection userInfo
            .where('email', isEqualTo: gUser.email).get();

        if (userSnapshot.docs.isNotEmpty) {
          // User already exists in Firestore.
          googleLoginDocID = userSnapshot.docs.first.id;  //get the docID
        }
        else {
          // User doesn't exist in Firestore, create a new document.

          final newGoogleUser = await FirebaseFirestore.instance.collection(
              'userInfo').add({
            'photoURL': gUser.photoUrl!,
            'username': gUser.displayName!,
            'email': gUser.email,
          });
          googleLoginDocID = newGoogleUser.id;
          await storage.write(key: 'googleLoginDocID',value: googleLoginDocID); //write this to the storage
          googleUserName = gUser.displayName!;

        }

        loggedInWithGoogle = true;

        return await FirebaseAuth.instance.signInWithCredential(credential);
      }
    } catch (e) { //Catch any errors which occur during the sign in process.
     // print('Error signing in with Google: $e');
      return null;
    }
  }
      signOut() async
      {
        if(loggedInWithGoogle == true)
        {
          await GoogleSignIn().signOut();
          await FirebaseAuth.instance.signOut();
          loggedInWithGoogle = false;

        }

        else if(loggedInWithPhone == true)
          {
            await FirebaseAuth.instance.signOut();
            loggedInWithPhone = false;
          }

      }


  signInWithApple() async {

 //   final SignInWithApple aUser = await   //Begin the Sign in with apple process.

    //final SignInWithApple? aUser =
  }

}


