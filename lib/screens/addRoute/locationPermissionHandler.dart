import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/myRoutes/myRoutes.dart';

class LocationPermissionHandler {
  final BuildContext context;
  late Timer _permissionTimer;

  LocationPermissionHandler({required this.context}) {
    checkLocationPermission();
    _permissionTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      checkLocationPermission();
    });
  }

  Future<void> checkLocationPermission() async {
    var status = await Permission.location.status;

    if (!status.isGranted) {
      showPermissionDialog();
    } else {
      // Location permission is granted, check if location service is enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        showLocationServiceDisabledDialog();
      }
    }
  }

  Future<void> showPermissionDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.level_5,
          title: const MyTexts(text: 'Location Permission', fontSize: 23),
          content: const MyTexts(text: 'Please grant location permission to use this app.', overflow: TextOverflow.visible),
          actions: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppColors.level_3),
              ),
              child: const MyTexts(text: 'OK'),
              onPressed: () async {
                Navigator.pop(context);
                await Permission.location.request();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showLocationServiceDisabledDialog() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.level_5,
          title: const MyTexts(text: 'Location Service Disabled', fontSize: 25,),
          content: const MyTexts(text: 'Please enable location service to use this app.'),
          actions: <Widget>[
            ElevatedButton(
              style: const ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(AppColors.level_3),
              ),
              child: const MyTexts(text: 'OK'),
              onPressed: () async {
                Navigator.pop(context);
                // Open location settings to allow user to enable location service
                await Geolocator.openLocationSettings();
              },
            ),
          ],
        );
      },
    );
  }

  void dispose() {
    _permissionTimer.cancel();
  }
}
