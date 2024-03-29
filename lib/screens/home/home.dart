import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:root/authentication/googleAuth.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/addRoute/addRoutePage.dart';

class HomePage extends StatefulWidget {
  final User user;

  HomePage({required this.user});

  @override
  State<HomePage> createState() => _HomePageState(user: user);
}

class _HomePageState extends State<HomePage> {
  GoogleAuth _auth = GoogleAuth();
  final User user;
  _HomePageState({required this.user});

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.level_2,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image(
            image: AssetImage("assets/background.png"),
          ),
          buildUserMailAndPhoto(user),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CardButton(
                imageAsset: "assets/addroute.png",
                buttonText: "Add New Route",
                onPressed: () {
                  showAddRouteDialog();
                },
              ),
              CardButton(
                imageAsset: "assets/myroutes.png",
                buttonText: "My Routes",
                onPressed: () {
                  // Handle onPressed action
                },
              ),
              CardButton(
                imageAsset: "assets/settings.png",
                buttonText: "Settings",
                onPressed: () {
                  // Handle onPressed action
                },
              ),
              CardButton(
                imageAsset: "assets/myroutes.png",
                buttonText: "Upgrade To Premium",
                onPressed: () async {
                  await _auth.signOutFromGoogleAccount();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildUserMailAndPhoto(User user) {
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.level_5,
            backgroundImage: NetworkImage(user.photoURL!),
          ),
          SizedBox(height: 20),
          Container(
            width: 270,
            height: MediaQuery.of(context).size.height * 0.08,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
              color: Colors.grey, // Set your desired background color
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? '',
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Montserrat',
                        color: AppColors.level_1, // Set your desired text color
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    user.email ?? '',
                    style: const TextStyle(
                      overflow: TextOverflow.ellipsis,
                      fontFamily: 'Montserrat',
                      color: Colors.black, // Set your desired text color
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void showAddRouteDialog() {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        backgroundColor: AppColors.level_6,
        title: const Text(
          'New Route',
          style: TextStyle(
            fontFamily: "Montserrat",
            fontWeight: FontWeight.bold,
            fontSize: 18.0,
            color: AppColors.level_5,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                constraints: BoxConstraints(
                  maxHeight: 50,
                ),
                fillColor: AppColors.level_5,
                filled: true,
                labelText: 'Route Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                constraints: BoxConstraints(
                  maxHeight: 50,
                ),
                fillColor: AppColors.level_5,
                filled: true,
                labelText: "Date",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onTap: () async {
                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2055),
                );
                if (picked != null) {
                  setState(() {
                    _dateController.text = '${picked.day}-${picked.month}-${picked.year}';
                  });
                }
              },
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              _nameController.clear();
              _dateController.clear();
              Navigator.of(context).pop();
            },
            child: Text('Cancel',
                style: TextStyle(
                    color: AppColors.level_5, fontFamily: "Montserrat", fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(AppColors.level_5),
            ),
            onPressed: () {
              final String name = _nameController.text;
              final String date = _dateController.text;
              // You can use the name and date for further processing
              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddRoutePage(),
              ));
            },
            child: Text(
              'Go to Maps',
              style:
                  TextStyle(color: AppColors.level_6, fontFamily: "Montserrat", fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class CardButton extends StatefulWidget {
  final String imageAsset;
  final String buttonText;
  final VoidCallback onPressed;

  const CardButton({
    required this.imageAsset,
    required this.buttonText,
    required this.onPressed,
  });

  @override
  _CardButtonState createState() => _CardButtonState();
}

class _CardButtonState extends State<CardButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
        widget.onPressed();
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      child: AnimatedContainer(
        duration: Duration(milliseconds: 150),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _isPressed ? AppColors.level_6 : AppColors.level_5,
              _isPressed ? AppColors.level_5 : AppColors.level_5,
              _isPressed ? AppColors.level_5 : AppColors.level_5,
              _isPressed ? AppColors.level_5 : AppColors.level_6,
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
          boxShadow: _isPressed
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8.0,
                    spreadRadius: 1.0,
                    offset: Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Image(
                height: 50,
                image: AssetImage(widget.imageAsset),
                color: AppColors.level_1, // Set your desired image color
              ),
              SizedBox(height: 10),
              Text(
                widget.buttonText,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: "Montserrat",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.level_1, // Set your desired text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
