
import 'package:flutter/material.dart';
import 'package:root/authentication/google_auth.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/my_texts.dart';
import 'package:root/screens/settings/help_and_support_page.dart';

class SettingsPage extends StatelessWidget {
  final GoogleAuth _auth = GoogleAuth();

  SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyTexts(text: 'Settings', fontSize: 23),
        backgroundColor: AppColors.level_3,
      ),
      body: ListView(
        children: ListTile.divideTiles(
          context: context,
          tiles: [
            ListTile(
              leading: const Icon(Icons.lock),
              title: const MyTexts(text: 'Logout'),
              onTap: () {
                _auth.signOutFromGoogleAccount();
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.help),
              title: const MyTexts(text: 'Help And Support'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                  return const HelpSupportPage();
                },));
              },
            ),
          ],
        ).toList(),
      ),
    );
  }
}
