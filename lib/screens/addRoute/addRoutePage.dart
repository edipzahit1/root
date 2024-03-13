import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/addRoute/draggableSheet.dart';
import 'package:root/screens/addRoute/locationPermissionHandler.dart';
import 'package:root/screens/addRoute/mapBuilder.dart';
import 'package:root/screens/addRoute/drawer.dart';

class AddRoutePage extends StatefulWidget {
  final int userID;
  AddRoutePage({required this.userID});

  @override
  State<AddRoutePage> createState() => _AddRoutePageState(userID: userID);
}

class _AddRoutePageState extends State<AddRoutePage> {
  int userID;
  _AddRoutePageState({required this.userID});

  @override
  void initState() {
    super.initState();
    LocationPermissionHandler permissionHandler =
        LocationPermissionHandler(context: context);
    permissionHandler.checkLocationPermission();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BuildMap(),
          DraggableSheet(),
        ],
      ),
    );
  }
}
