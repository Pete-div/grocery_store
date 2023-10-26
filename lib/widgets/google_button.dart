import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:gostery/consts/firebase_const.dart';
import 'package:gostery/fetch_screen.dart';
import 'package:gostery/screens/btm_bar.dart';
import 'package:gostery/services/global_methods.dart';
import 'package:gostery/widgets/text_widget.dart';

class GoogleButton extends StatelessWidget {
  GoogleButton({Key? key}) : super(key: key);
  bool _isLoading = false;
  Future<void> _googleSignIn(context) async {
    final googleSignIn = GoogleSignIn();
    final googleAccountion = await googleSignIn.signIn();
    if (googleAccountion != null) {
      final googleAuth = await googleAccountion.authentication;
      if (googleAuth.accessToken != null && googleAuth.idToken != null) {
        try {
          final authResult = await authInstance.signInWithCredential(
              GoogleAuthProvider.credential(
                  idToken: googleAuth.idToken,
                  accessToken: googleAuth.accessToken));
          if (authResult.additionalUserInfo!.isNewUser) {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(authResult.user!.uid)
                .set({
              'id': authResult.user!.uid,
              'name': authResult.user!.displayName,
              'email': authResult.user!.email,
              'shipping-address': '',
              'userWish': [],
              'userCart': [],
              'createdAt': Timestamp.now(),
            });
          }
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const FetchScreen(),
            ),
          );
          Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const BottomBarScreen()));
        } on FirebaseAuthException catch (err) {
          GlobalMethods.errorDialog(
              subtitle: "${err.message}", context: context);
        } catch (err) {
          GlobalMethods.errorDialog(subtitle: "$err", context: context);
        } finally {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.blue,
      child: InkWell(
        onTap: () {
          _googleSignIn(context);
        },
        child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
          Container(
            color: Colors.white,
            child: Image.asset(
              'assets/images/google.png',
              width: 40.0,
            ),
          ),
          const SizedBox(
            width: 8,
          ),
          TextWidget(
              text: 'Sign in with google', color: Colors.white, textSize: 18)
        ]),
      ),
    );
  }
}
