import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:alfaaz/pages/authentication/user_info_page.dart';

class Authentication {
  static late UserCredential emailUser;

  static void setUserCredential(credential) {
    emailUser = credential;
  }

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    String orgCode="";
    User? user = FirebaseAuth.instance.currentUser;
    // FirebaseDatabase.instance.reference().child("organisation").orderByChild("users").orderByChild("email").equalTo(user!.email).onChildAdded.listen((event) {
    //   orgCode=event.snapshot.key!;
    //   print(orgCode);
    // });
    if (user != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              UserInfoPage(
                user: user,
                orgCode:""// new FlutterSecureStorage().read(key: 'organisationCode') as String,
              ),
        ),
      );
    }

    return firebaseApp;
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }

  static Future<bool> signOut({required BuildContext context}) async {

    try {
      // if (!kIsWeb) {
      //   await FirebaseAuth.instance.signOut();
      // }
      await FirebaseAuth.instance.signOut();
      return true;
    } catch ( e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        Authentication.customSnackBar(
          content: 'Error signing out. Try again.',
        ),

      );
      return false;
    }
  }
}