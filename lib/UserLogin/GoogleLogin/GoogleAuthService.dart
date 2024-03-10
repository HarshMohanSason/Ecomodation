

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../main.dart';


class GoogleAuthentication extends ChangeNotifier {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; //Firebase sign in instance
  final GoogleSignIn googleSignIn = GoogleSignIn(); //google Sign in instance

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool? _isSignedInWithGoogle;
  bool? get isSignedInWithGoogle => _isSignedInWithGoogle;

  bool? _hasError;
  bool? get hasError => _hasError;

  String? _provider;
  String? get provider => _provider;

  bool? _isSignedIn;
  bool? get isSignedIn => _isSignedIn;

  String? _uid;
  String? get uid => _uid;

  String? _username;
  String? get username => _username;

  String? _email;
  String? get email => _email;

  String? _imageURL;
  String? get imageURL => _imageURL;

  //Function for Google Login
  Future signInWithGoogle() async {

    _isLoading = true;
    notifyListeners();

    final GoogleSignInAccount? gUser = await googleSignIn.signIn();

    if (gUser != null) {
      try {
        final GoogleSignInAuthentication gAuth = await gUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: gAuth.accessToken,
          idToken: gAuth.idToken,
        );

        //sign the user in using Firebase
        final User userDetails =
            (await firebaseAuth.signInWithCredential(credential)).user!;

        _username = userDetails.displayName;
        _email = userDetails.email;
        _imageURL = userDetails.photoURL;
        _uid = userDetails.uid;
        _provider = "GOOGLE";
        _isSignedInWithGoogle = true;
        _isSignedIn = true;
        await saveIfLoggedToLocalStorage(); //save that the user has logged in successfully
        notifyListeners();

        if (!await checkUserExists()) {
          await saveDataToFirestore();  //Save data to firestore if doesn't exist in the db
        }
        _isLoading = false;
        notifyListeners();

      } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case "account-exists-with-different-credential":
            _errorCode =
                "You already have an account with us. Use correct provider";
            _hasError = true;
            _isLoading = false;
            notifyListeners();
            break;

          case "null":
            _errorCode = "Some unexpected error came while trying to sign in";
            _hasError = true;
            _isLoading = false;
            //print("nothing");
            notifyListeners();
            break;

          default:
            _errorCode = e.toString();
            _hasError = true;
            _isLoading = false;
            notifyListeners();
        }
      }
    } else {
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }


  Future googleSignOut() async {


      _isLoading = false;
      _isSignedIn = false;
      storage.deleteAll();
      await googleSignIn.signOut();
      await FirebaseAuth.instance.signOut();
      notifyListeners();
    }

  //check if the userExists already
  Future<bool> checkUserExists() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  //Function to save the Data to the firestore database
  Future saveDataToFirestore() async {

    final docSnapshot = FirebaseFirestore.instance.collection('userInfo').doc(uid);
    await docSnapshot.set({
      "username": _username,
      "email": _email,
      "imageURL": _imageURL,
      "uid": _uid,
      "provider": _provider,
    });
    notifyListeners();
  }

  //Get user Data from Firestore
  Future getUserDataFromFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('userInfo')
          .doc(uid)
          .get()
          .then((snapshot) {
        _uid = snapshot["uid"];
        _username = snapshot["username"];
        _email = snapshot["email"];
        _imageURL = snapshot["imageURL"];
        _provider = snapshot["provider"];
      });
    } catch (e) {
      return null;
    }
  }

  //Save the data to the local Storage
  Future<void> saveIfLoggedToLocalStorage() async {

    if ( !await storage.containsKey(key: 'LoggedIn')) {
      await storage.write(key: 'LoggedIn', value: "True");
    }
    else
      {
        return;
      }
  }


}
