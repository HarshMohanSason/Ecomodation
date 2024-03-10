
import 'package:ecomodation/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:rsa_encrypt/rsa_encrypt.dart';
import 'package:pointycastle/pointycastle.dart' as crypto;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../UserLogin/GoogleLogin/GoogleAuthService.dart';
import '../UserLogin/PhoneLogin/LoginWithPhoneUI.dart';

/*
    * Generate a public key and a private key
    * The public key will get stored in the userInfo collection in firebase
    * The private key will be stored in securely on the user's device using
    flutter's secure package
    * Each a chat window is opened, the public key is also retrieved to encrypt
    the sent messages
    * The private key stored in the user's device will be used to decrypt all
    the messages

    (The keys will be refreshed after a period of 3-6 months)

 */

//class to define the methods for the encryption

class RSAEncryption {

  Future<crypto.AsymmetricKeyPair<crypto.PublicKey, crypto.PrivateKey>> getKeyPair() //function to generate the keys (public and private) 
  {
    var keyHelper = RsaKeyHelper(); //call the class constructor

    return keyHelper.computeRSAKeyPair(keyHelper.getSecureRandom()); //return the pair of keys using the SecureRandom Package
  }

  //function to upload the keys to secure Storage and to userCollection document
  Future<void> uploadKeys() async
  {
    var getKeyPairs =  await getKeyPair(); //get the keyPairs;

    try {
      //if the storage does not contain a privateKey
      if (!await(storage.containsKey(key: 'privateKey: p'))) {
        var getPrivateKey = getKeyPairs.privateKey as RSAPrivateKey;

        await storage.write(key: 'privateKey: p', value: getPrivateKey.p.toString()); //write the private key to the storage.
        await storage.write(key: 'privateKey: q', value: getPrivateKey.q.toString());
        await storage.write(key: 'privateKey: privateExp', value: getPrivateKey.privateExponent.toString());
        await storage.write(key: 'privateKey: modulus', value: getPrivateKey.modulus.toString());

        var getPublicKey = getKeyPairs.publicKey as RSAPublicKey;
        var uploadPublicKeyObject = {
          'n': getPublicKey.n!.toString(),
          'E': getPublicKey.publicExponent!.toString(),
        };

        FirebaseFirestore.instance.collection(
            'userInfo') //get the reference to the userCollection
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .update({'publicKey': uploadPublicKeyObject});
      }
      }
    catch(e)
    {
      rethrow; //rethrow the error
    }
}

  Future<RSAPublicKey> getReceiverPublicKey(String receiverID) async //get the public key for the user who we are sending the message to
  {
    var getPublicKey = await FirebaseFirestore.instance.collection('userInfo').doc(receiverID).get().then((value) => value.data()?['publicKey']);

    RSAPublicKey getNewPublicKey = RSAPublicKey(BigInt.parse(getPublicKey['n']), BigInt.parse(getPublicKey['E']));

    return getNewPublicKey;
  }

  Future<RSAPublicKey> getOwnPublicKey() async
  {
    var getPublicKey = await FirebaseFirestore.instance.collection('userInfo').doc(FirebaseAuth.instance.currentUser!.uid).get().then((value) => value.data()?['publicKey']);

    RSAPublicKey getNewPublicKey = RSAPublicKey(BigInt.parse(getPublicKey['n']), BigInt.parse(getPublicKey['E']));

    return getNewPublicKey;
  }

  Future<RSAPrivateKey> getPrivateKey() async
  {
    String? pOld = await storage.read(key: 'privateKey: p');
    BigInt? pNew = BigInt.parse(pOld!);

    String? qOld = await storage.read(key: 'privateKey: q');
    BigInt? qNew = BigInt.parse(qOld!);

    String? oldPrivateExponent = await storage.read(key: 'privateKey: privateExp');
    BigInt newPrivateExponent = BigInt.parse(oldPrivateExponent!);

    String? oldModulus = await storage.read(key: 'privateKey: modulus');
    BigInt newModulus = BigInt.parse(oldModulus!);

    RSAPrivateKey getNewPrivateKey = RSAPrivateKey(newModulus, newPrivateExponent, pNew, qNew);

    return getNewPrivateKey;
  }
}