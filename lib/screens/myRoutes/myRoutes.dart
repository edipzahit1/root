import 'package:flutter/material.dart';
import 'package:root/main/main.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/models/route.dart' as RootRoute;
import 'package:root/screens/addRoute/addRoutePage.dart';

class MyRoutesPage extends StatefulWidget {
  const MyRoutesPage({super.key});

  @override
  State<MyRoutesPage> createState() => _MyRoutesPageState();
}

class _MyRoutesPageState extends State<MyRoutesPage> {
  late Stream<List<Map<String, dynamic>>> routesStream;

  @override
  void initState() {
    super.initState();
    routesStream = RootRoute.Route().getRoutesStream(globalUser!.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.level_2,
      appBar: AppBar(
        backgroundColor: AppColors.level_6,
        title: const MyTexts(text: "My Routes", fontSize: 25, fontWeight: FontWeight.bold,),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: routesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Loading indicator
          }
          if (!snapshot.hasData) {
            return const Text('No routes found'); // Placeholder text
          }
          List<Map<String, dynamic>> routes = snapshot.data!;
          if (routes.isEmpty) {
            print("EMPTYYY");
          }
          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              List<Map<String, double>> convertedLocations = [];
              if (routes[index]["locations"] != null) {
                // Cast each location to Map<String, double>
                convertedLocations =
                    (routes[index]["locations"] as List<dynamic>)
                        .map((location) => Map<String, double>.from(location))
                        .toList();
              }
              return RouteCard(
                routeName: routes[index]['routeName'],
                date: routes[index]['date'],
                onDelete: () {
                  RootRoute.Route()
                      .deleteRoute(routeName: routes[index]['routeName']);
                },
                locations: convertedLocations, // Pass the converted locations
              );
            },
          );
        },
      ),
    );
  }
}

class RouteCard extends StatelessWidget {
  final String routeName;
  final DateTime? date;
  final VoidCallback onDelete;
  final List<Map<String, double>> locations;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return ''; // Return an empty string if DateTime is null
    }
    return '${dateTime.year}-${dateTime.month}-${dateTime.day}';
  }

  const RouteCard(
      {Key? key,
      required this.routeName,
      required this.date,
      required this.onDelete,
      required this.locations})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.level_3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: [
                    Icon(Icons.location_on, color: AppColors.level_5),
                    SizedBox(width: 10),
                    Expanded(
                      child: MyTexts(
                        text: routeName,
                        fontSize: 29,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 10),
                    MyTexts(text: _formatDate(date)),
                  ],
                ),
                Row(  
                  children: <Widget>[
                    const Spacer(),
                    TextButton(
                      child: const MyTexts(text: "Update"),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => AddRoutePage()));
                      },
                    ),
                    TextButton(
                      child: const MyTexts(text: "Start Navigation"),
                      onPressed: () {
                        //WE WILL CALL GOOGLE MAPS WITH NAVIGATION
                      },
                    ),
                    TextButton(
                      child: const MyTexts(text: "Delete"),
                      onPressed: () {
                        showDeleteConfirmationDialog(context, onDelete);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, VoidCallback onDeleted) async {
    showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.level_5,
          title: const MyTexts(text: "Delete Route", fontSize: 25),
          content: const MyTexts(
            text: 'Are you sure you want to delete this route?',
            overflow: TextOverflow.visible,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Close the dialog and return false
              },
              child: const MyTexts(text: "Cancel"),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.of(context)
                    .pop(true); // Close the dialog and return true
              },
              child: const MyTexts(text: "Delete"),
            ),
          ],
        );
      },
    );
  }
}

class MyTexts extends StatelessWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;

  const MyTexts({
    Key? key,
    required this.text,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.overflow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? AppColors.level_1,
        fontSize: fontSize ?? 15,
        fontWeight: fontWeight ?? FontWeight.w600,
        fontFamily: "Montserrat",
        overflow: overflow ?? TextOverflow.ellipsis,
        fontStyle: fontStyle ?? FontStyle.normal,
      ),
    );
  }
}
