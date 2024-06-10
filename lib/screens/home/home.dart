
import 'package:animated_notch_bottom_bar/animated_notch_bottom_bar/animated_notch_bottom_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:root/authentication/googleAuth.dart';
import 'package:root/main/main.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/screens/addRoute/addRoutePage.dart';
import 'package:root/screens/myRoutes/myRoutes.dart';
import 'package:root/models/route.dart' as RootRoute;

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GoogleAuth _auth = GoogleAuth();
  final _pageController = PageController(initialPage: 0);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: AnimatedNotchBottomBar(
              notchBottomBarController: NotchBottomBarController(index: 0),
              color: AppColors.level_3,
              showLabel: false,
              notchColor: AppColors.level_6,
              removeMargins: false,
              bottomBarWidth: 500,
              durationInMilliSeconds: 300,
              bottomBarItems: [
                BottomBarItem(
                  inActiveItem: Image(image: AssetImage("assets/myroutes.png"), color: AppColors.level_6,),
                  activeItem: Image(image: AssetImage("assets/myroutes.png"), color: AppColors.level_5,),
                ),
                BottomBarItem(
                  inActiveItem: Image(image: AssetImage("assets/addroute.png")),
                  activeItem: Image(image: AssetImage("assets/addroute.png")),
                ),
              ],
              onTap: (index) {
                _pageController.jumpToPage(index);
              }, kIconSize: 25, kBottomRadius: 0,
            ),
      backgroundColor: AppColors.level_2,
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        children: [
          buildUserMailAndPhoto(),
          MyRoutesPage(),
        ],
      ),
      extendBody: true,
    );
  }

  Widget buildUserMailAndPhoto() {
    return Padding(
      padding: const EdgeInsets.only(top: 100, left: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: AppColors.level_5,
            backgroundImage: NetworkImage(globalUser!.photoURL!),
          ),
          const SizedBox(height: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    globalUser!.displayName ?? '',
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontFamily: 'Montserrat',
                        color: AppColors.level_1, // Set your desired text color
                        fontWeight: FontWeight.bold,
                        fontSize: 16),
                  ),
                  Text(
                    globalUser!.email ?? '',
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
                constraints: const BoxConstraints(
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
            const SizedBox(height: 16),
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                floatingLabelBehavior: FloatingLabelBehavior.never,
                constraints: const BoxConstraints(
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
                    _dateController.text =
                        '${picked.day}-${picked.month}-${picked.year}';
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
            child: const Text('Cancel',
                style: TextStyle(
                    color: AppColors.level_5,
                    fontFamily: "Montserrat",
                    fontWeight: FontWeight.bold)),
          ),
          ElevatedButton(
            style: const ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(AppColors.level_5),
            ),
            onPressed: () async {
              final String name = _nameController.text;
              final String dateString = _dateController.text;

              DateTime? date;
              if (dateString.isNotEmpty) {
                final List<String> dateParts = dateString.split('-');
                if (dateParts.length == 3) {
                  final int day = int.tryParse(dateParts[0]) ?? 1;
                  final int month = int.tryParse(dateParts[1]) ?? 1;
                  final int year =
                      int.tryParse(dateParts[2]) ?? DateTime.now().year;
                  date = DateTime(year, month, day);
                }
              }

              if (name.isNotEmpty && date != null) {
                try {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user != null) {
                    await RootRoute.Route().addRoute(
                      routeName: name,
                      date: date,
                      locations: [], // Pass the locations if needed
                    );
                    print('Route added successfully');
                  }
                } catch (e) {
                  print('Error adding route: $e');
                }
              } else {
                print('Invalid route name or date');
              }

              Navigator.of(context).pop();
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => AddRoutePage(),
              ));
            },
            child: const Text(
              'Go to Maps',
              style: TextStyle(
                  color: AppColors.level_6,
                  fontFamily: "Montserrat",
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
