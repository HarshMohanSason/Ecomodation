import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class Authentication {

  static Future <FirebaseApp> initializeFirebase() async  //create a async function
  {
    FirebaseApp firebaseApp = await Firebase.initializeApp();  // Use the await keyword to wait for initialization to complete

    return firebaseApp; //return the firebaseApp when initialized
  }

  //Function to implement signInWith Google;

    signInWithGoogle() async {

    final GoogleSignInAccount? gUser = await GoogleSignIn().signIn();  //Begin the sign in process

    final GoogleSignInAuthentication gAuth = await gUser!.authentication;  //Get authentication details form request

    final credential = GoogleAuthProvider.credential(  //credential method, get the credentials with certain API accesses
      accessToken: gAuth.accessToken,
      idToken: gAuth.idToken,
    );
  return await FirebaseAuth.instance.signInWithCredential(credential); //pass the credentials to the signInWithCredential method
  }

  signInWithApple() async {

 //   final SignInWithApple aUser = await   //Begin the Sign in with apple process.

    //final SignInWithApple? aUser =
  }

}


