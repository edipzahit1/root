import 'package:flutter/material.dart';
import 'package:root/authentication/googleAuth.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/addRoute/addRoutePage.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GoogleAuth googleAuth = new GoogleAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Padding(
              padding: EdgeInsets.only(bottom: 100),
              child: buildgoogleSignInButton(),
            ),
          ],
        ),
      ]),
    );
  }

  Widget buildgoogleSignInButton() {
    final MyButtonStyle myButtonStyle = new MyButtonStyle();

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.07,
        decoration: myButtonStyle.decorateBox(),
        child: MaterialButton(
          onPressed: () async {
            final currentUserId = await googleAuth.signInToGoogleAccount();
            if (currentUserId == -1) {
              print("Error signing in");
            } else {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) {
                  return AddRoutePage(userID: currentUserId);
                },
              ));
            }
          },
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.account_circle,
                color: AppColors.level_4,
              ),
              SizedBox(width: 10),
              Text(
                "Sign In With Google",
                style: TextStyle(
                  color: AppColors.level_4,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
