import 'package:firebase_core/firebase_core.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late final googleLoginDocID;
bool loggedinWithGoogle = false;

class Authentication {

  final writeUserInfo = FirebaseFirestore.instance.collection('userInfo'); //refer to the collection userInfo
  final readUserInfo = FirebaseFirestore.instance.collection('userInfo'); //refer to read the data

  //create an instance to write data to firebase
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

    var docSnapshot = await readUserInfo.get(); //wait to get the user info
    bool userExists = false;
    for(var eachDocument in docSnapshot.docs)
    {
      Map<String, dynamic> data = eachDocument.data(); //get the document data
      var email = data['email']; //store the email for each document

      if (email == gUser.email) //if the email matches, that means user already logged in, no need to write data again.
          {
        userExists = true;
        googleLoginDocID = eachDocument.id;
        break;
          }
     }

       if(userExists == false)
          {
            var newGoogleUser = await writeUserInfo.add({'username': gUser.displayName, 'email': gUser.email}); //if no email found, write the data.
            googleLoginDocID = newGoogleUser.id; //get the loginID
          }

    loggedinWithGoogle = true;
    return await FirebaseAuth.instance.signInWithCredential(credential); //pass the credentials to the signInWithCredential method
      }


  signInWithApple() async {

 //   final SignInWithApple aUser = await   //Begin the Sign in with apple process.

    //final SignInWithApple? aUser =
  }

}


