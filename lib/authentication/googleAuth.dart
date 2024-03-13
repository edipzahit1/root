import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:root/main/databaseHelper.dart';
import 'package:root/models/GoogleUser.dart';

class GoogleAuth {
  
  Future<int> signInToGoogleAccount() async{
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      
      if (googleUser == null) {
        return -1;  //user canceled
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      //creating new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      //after signed in returnin the UserCredential
      final UserCredential userCredential = 
        await FirebaseAuth.instance.signInWithCredential(credential);

      final GoogleUser user = GoogleUser(
        id: userCredential.user!.uid,
        email: userCredential.user!.email,
        photoURL: userCredential.user!.photoURL,
      );

      final DatabaseHelper db = DatabaseHelper.instance;

      return await db.insertUserInfo(user.toMap());

    } catch (e) {
      print(e);
      return -1;
    }
  }

  Future signOutFromGoogleAccount() async {
    try {
      await GoogleSignIn().signOut();
      await FirebaseAuth.instance.signOut();
    } catch(e) {
      print("Exception on signing out" + e.toString());
    }
  }
}
