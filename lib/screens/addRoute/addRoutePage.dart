import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/addRoute/draggableSheet.dart';
import 'package:root/screens/addRoute/locationPermissionHandler.dart';
import 'package:root/screens/addRoute/mapBuilder.dart';

class AddRoutePage extends StatefulWidget {
  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
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
      appBar: AppBar(
        backgroundColor: AppColors.level_1,
        leading: CircleAvatar(
          backgroundColor: AppColors.level_5,
          child: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
      ),
      body: Stack(
        children: [
          BuildMap(),
          DraggableSheet(),
        ],
      ),
    );
  }
}
