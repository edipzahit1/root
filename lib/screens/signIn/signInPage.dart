import 'package:flutter/material.dart';
import 'package:root/authentication/googleAuth.dart';
import 'package:root/preferences/buttons.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  GoogleAuth _auth = GoogleAuth();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.level_2,
      body: Stack(children: [
        const Image(image: AssetImage("assets/background.png")),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildAppLogo(),
            SizedBox(height: 70),
            buildGoogleSignInButton(),
          ],
        ),
      ]),
    );
  }

  Widget buildAppLogo() {
    return Container(
      child: CircleAvatar(
        radius: 100,
        backgroundColor: AppColors.level_1,
      ),
    );
  }

  Widget buildGoogleSignInButton() {
    return Container(
        alignment: Alignment.center,
        child: Expanded(
          child: ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(AppColors.level_5),
            ),
            onPressed: () async {
              await _auth.signInToGoogleAccount();
            },
            child: const Text("Sign In With Google",
                style: TextStyle(
                    color: AppColors.level_1,
                    fontFamily: "Montserrat",
                    fontSize: 20,
                    fontWeight: FontWeight.bold)),
          ),
        ));
  }
}
