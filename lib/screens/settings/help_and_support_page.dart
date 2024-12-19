import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/my_texts.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const MyTexts(text: 'Help & Support'),
        backgroundColor:
            AppColors.level_5, // Adjust the color as per your theme
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.email),
            title: const MyTexts(text: 'Email Us'),
            subtitle: const MyTexts(
                text: 'edipzahit1@gmail.com'), // Replace with your actual email
            onTap: () => _launchEmail('edipzahit1@gmail.com'),
          ),
        ],
      ),
    );
  }

  void _launchEmail(String email) async {
    Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'edipzahit1@gmail.com',
      query: encodeQueryParameters(
          {'subject': 'From Root', 'body': 'Hello, I need help with...'}),
    );
    if (await canLaunchUrl(emailLaunchUri)) {
      bool launched = await launchUrl(emailLaunchUri);
      if (!launched) {
        print('Failed to launch $emailLaunchUri');
      } 
    } else {
      print('Could not launch $emailLaunchUri');
    }
  }

  String encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
