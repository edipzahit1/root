import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/home/home.dart';
import 'package:root/screens/signIn/sign_in_page.dart';

User? globalUser;

void main() async {
  await dotenv.load(fileName: ".env");
  final fireBaseOpApiKey = dotenv.env["FIREBASE_OP_API_KEY"];

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "$fireBaseOpApiKey",
          appId: "1:662203921507:android:199fb746c61d61323cb456",
          messagingSenderId: "662203921507",
          projectId: "root-415310"));

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: AppColors.level_1),
      debugShowCheckedModeBanner: false,
      home: const Root(),
    );
  }
}

class Root extends StatefulWidget {
  const Root({super.key});
  @override
  State<Root> createState() => _RootState();
}

class _RootState extends State<Root> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: _auth.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            if (snapshot.hasData) {
              globalUser = snapshot.data;
              return const HomePage();
            } else {
              return const SignInPage();
            }
          }
        });
  }
}
