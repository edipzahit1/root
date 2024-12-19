import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleAuth {
  Future<void> signInToGoogleAccount() async{
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        return;  //user canceled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      //creating new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      //after signed in returnin the UserCredential
      await FirebaseAuth.instance.signInWithCredential(credential);

    } catch (e) {
      print(e);
      return;
    }
  }

  Future signOutFromGoogleAccount() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch(e) {
      print("Exception on signing out$e");
    }
  } 
}
