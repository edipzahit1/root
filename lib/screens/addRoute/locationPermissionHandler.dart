import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:root/preferences/buttons.dart';

class LocationPermissionHandler {

  final BuildContext context;

  LocationPermissionHandler({required this.context});

  Future<void> checkLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      showPermissionDialog();
    }
  }

  Future<void> showPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.level_1,
          title: Text('Location Permission'),
          content: Text('Please grant location permission to use this app.'),
          actions: <Widget>[
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppColors.level_3),
              ),
              child: Text('OK'),
              onPressed: () async {
                Navigator.pop(context);

                await Permission.location.request();

                checkLocationPermission();
              },
            ),
          ],
        );
      },
    );
  }
  
}