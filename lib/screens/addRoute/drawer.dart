import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:root/authentication/googleAuth.dart';
import 'package:root/main/databaseHelper.dart';
import 'package:root/preferences/buttons.dart';

class BuildDrawer extends StatefulWidget {
  final int userID;
  BuildDrawer({required this.userID});

  @override
  State<BuildDrawer> createState() => _BuildDrawerState(userID: this.userID);
}

class _BuildDrawerState extends State<BuildDrawer> {
  final GoogleAuth googleAuth = new GoogleAuth();
  final int userID;
  _BuildDrawerState({required this.userID});

  DatabaseHelper db = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.6,
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.level_6, AppColors.level_5],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: <Widget>[
            FutureBuilder<Map<String, dynamic>?>(
              future: getPhoto(userID),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  return Text('Error loading photo');
                } else if (snapshot.hasData && snapshot.data != null) {
                  String? photoPath = snapshot.data!['photo']; 
                  if (photoPath != null && photoPath.isNotEmpty) {
                    return CircleAvatar(
                      backgroundImage: NetworkImage(photoPath),
                    );
                  } else {
                    return Text('Photo not found');
                  }
                } else {
                  // If no data is available, show a default message
                  return Text('No photo available');
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, dynamic>?> getPhoto(int userID) async {
    return await db.queryUserInfo(userID);
  }
}
