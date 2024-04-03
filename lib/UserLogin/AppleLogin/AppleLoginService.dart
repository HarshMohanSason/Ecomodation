
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../main.dart';
import 'package:crypto/crypto.dart';

class AppleLoginService extends ChangeNotifier {

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance; //firebase auth instance
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _didPromptToLogin = false;
  bool get didPromptToLogin => _didPromptToLogin;

  String? _errorCode;
  String? get errorCode => _errorCode;

  bool? _isSignedIn;
  bool? get isSignedIn => _isSignedIn;

  bool? _hasError;
  bool? get hasError => _hasError;

  String? _provider;
  String? get provider => _provider;

  String? _uid;
  String? get uid => _uid;

  String? _username;

  String? get username => _username;

  String? _email;
  String? get email => _email;

  String? _imageURL;
  String? get imageURL => _imageURL;


  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<void> appleLogin() async {

    _isLoading = true;
    notifyListeners();

    try {
      final rawNonce = generateNonce();
      final nonce = sha256ofString(rawNonce);
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: nonce,
      );


      // Check if the user canceled the sign-in process
      if (appleCredential.identityToken == null) {
        _isLoading = false;
        notifyListeners();
        return; // Exit the method without further processing
      }

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        rawNonce: rawNonce,
      );

      final authResult = await firebaseAuth.signInWithCredential(oauthCredential);
      _email = appleCredential.email ?? "";
      _username = await storage.read(key: 'appleUserName') ?? appleCredential.givenName ;
      authResult.user!.displayName ?? await firebaseAuth.currentUser!.updateDisplayName(_username);
      _imageURL = "";
      _uid = authResult.user!.uid;
      _provider = "APPLE";
      _isSignedIn = true;

      if (!await checkUserExists() && authResult.credential!.token != null &&  appleCredential.identityToken != null) {
        await saveDataToFirestore();
      }
      _isLoading = false;
      notifyListeners();
    } on SignInWithAppleAuthorizationException {
      _isLoading = false;
      _hasError = true;
      notifyListeners();
    } on FirebaseAuthException catch (e) {

      switch (e.code) {
        case "account-exists-with-different-credential":
          _errorCode = "You already have an account with us. Use correct provider";
          break;
        case "null":
          _errorCode = "Some unexpected error occurred while trying to sign in";
          break;
        default:
          _errorCode = e.toString();
      }
      _hasError = true;
      _isLoading = false;
      notifyListeners();
    }
  }
    //Function to sign the userOUT
    Future signOut() async
    {
      await firebaseAuth.signOut();
      await storage.delete(key: 'LoggedIn');
      _isSignedIn = false;
      _isLoading = false;
      notifyListeners();

    }
    //check if the userExists already
    Future<bool> checkUserExists() async {
      try {
        var snapshot = await FirebaseFirestore.instance.collection('userInfo').doc(uid).get();

        if (snapshot.exists) {
          return true;
        }
        return false;
      }
      catch (e) {
        rethrow;
      }
    }

    //Function to save the Data to the firestore database
    Future saveDataToFirestore() async
    {
      try {
        final docSnapshot = FirebaseFirestore.instance.collection('userInfo')
            .doc(uid);
        await docSnapshot.set({
          "username": _username,
          "email": _email,
          "imageURL": _imageURL,
          "uid": _uid,
          "provider": _provider,
        });
        storage.write(key: 'appleUserName', value: _username);
        notifyListeners();
      }
      catch (e) {
        throw e.toString();
      }
    }

    Future deleteAppleRelatedAccount() async {
      try {
        FirebaseFirestore.instance.collection('userInfo').doc(firebaseAuth.currentUser!.uid).delete();
        FirebaseAuth.instance.currentUser!.delete();
        await storage.delete(key: 'LoggedIn');
      }
      catch (e) {
        throw e.toString();
      }
    }
  }