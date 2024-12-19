import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:root/main/main.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/my_texts.dart';
import 'package:root/screens/addRoute/add_route_page.dart';
import 'package:root/screens/myRoutes/my_routes.dart';
import 'package:root/models/route.dart' as RootRoute;
import 'package:root/screens/settings/settings.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int _selectedIndex = 0;

  void _openBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => buildBottomSheet(),
      isScrollControlled: true,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.level_2,
      appBar: AppBar(
        title: const MyTexts(text: 'Route Planner', fontSize: 20),
        backgroundColor: AppColors.level_3,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: AppColors.level_1),
              label: const MyTexts(
                text: 'Add Route',
                fontSize: 15,
              ),
              style: ButtonStyle(
                backgroundColor:
                    const WidgetStatePropertyAll(AppColors.level_5),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                elevation: const WidgetStatePropertyAll(4),
                shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                )),
                padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              ),
              onPressed: () {
                _openBottomSheet();
              },
            ),
          )
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          buildProfileSection(),
          const MyRoutesPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.level_5,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'My Routes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: AppColors.level_1,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget buildProfileSection() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background image
            ClipOval(
              child: Opacity(
                opacity: 0.5, // Optional: Adjust opacity for background image
                child: Image.asset(
                  'assets/background.png', // Use your asset image path
                  fit: BoxFit.cover,
                  width: 150,
                  height: 150,
                ),
              ),
            ),
            // Profile picture
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(globalUser!.photoURL!),
            ),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          globalUser!.displayName ?? 'No Name',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.level_5),
        ),
        Text(
          '${globalUser!.email}',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 20),
        buildMenu(),
      ],
    );
  }

  Widget buildMenu() {
    return Column(
      children: [
        buildMenuItem(
          Icons.settings,
          "Settings",
          onTap: () {
            Navigator.of(context).push(MaterialPageRoute(
              builder: (context) {
                return SettingsPage();
              },
            ));
          },
        ),
      ],
    );
  }

  Widget buildMenuItem(IconData icon, String title, {Function()? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.level_5,),
      title: MyTexts(text: title, color: AppColors.level_3,),
      trailing: const Icon(Icons.arrow_forward_ios, color: AppColors.level_5,),
      onTap: onTap,
    );
  }

  @override
  void dispose() {
    _pageController.dispose(); // Don't forget to dispose controllers
    super.dispose();
  }

  Widget buildBottomSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 1,
      minChildSize: 0.3,
      maxChildSize: 1,
      builder: (_, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.level_6,
          ),
          padding: const EdgeInsets.all(20),
          child: ListView(
            padding: const EdgeInsets.only(top: 300),
            controller: controller,
            children: [
              const MyTexts(text: 'Add New Route', fontSize: 20),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                    labelText: 'Route Name',
                    fillColor: AppColors.level_5,
                    filled: true),
              ),
              TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                    labelText: 'Date',
                    fillColor: AppColors.level_5,
                    filled: true),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2200),
                  );
                  if (picked != null) {
                    _dateController.text =
                        '${picked.day}-${picked.month}-${picked.year}';
                  }
                },
              ),
              ElevatedButton(
                style: const ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(AppColors.level_5)),
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
                    builder: (context) => AddRoutePage(routeName: name),
                  ));
                },
                child: const MyTexts(text: "Save Route"),
              )
            ],
          ),
        );
      },
    );
  }
}
