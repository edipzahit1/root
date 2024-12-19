
import 'package:flutter/material.dart';
import 'package:root/main/main.dart';
import 'package:root/models/location.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/models/route.dart' as RootRoute;
import 'package:root/preferences/my_texts.dart';
import 'package:root/screens/addRoute/add_route_page.dart';
import 'package:root/screens/opt/optimize.dart';
import 'package:root/screens/showRouteAndNav/show_route.dart';

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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: routesStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No routes found'));
          }
          List<Map<String, dynamic>> routes = snapshot.data!;
          return ListView.builder(
            itemCount: routes.length,
            itemBuilder: (context, index) {
              List<Map<String, dynamic>> convertedLocations = [];
              if (routes[index]["locations"] != null) {
                convertedLocations =
                    (routes[index]["locations"] as List<dynamic>)
                        .map((location) => {
                              'latitude': location['latitude'],
                              'longitude': location['longitude'],
                              'country': location['country'],
                              'vicinity': location['vicinity'],
                            })
                        .toList();
              }
              return RouteCard(
                routeName: routes[index]['routeName'],
                date: routes[index]['date'],
                onDelete: () {
                  RootRoute.Route()
                      .deleteRoute(routeName: routes[index]['routeName']);
                },
                locations: convertedLocations,
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
  final List<Map<String, dynamic>> locations;

  String _formatDate(DateTime? dateTime) {
    if (dateTime == null) {
      return '-/-/-';
    }
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  const RouteCard({
    Key? key,
    required this.routeName,
    required this.date,
    required this.onDelete,
    required this.locations,
  }) : super(key: key);

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
                    const Icon(Icons.location_on, color: AppColors.level_5),
                    const SizedBox(width: 10),
                    Expanded(
                      child: MyTexts(
                        text: routeName,
                        fontSize: 29,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
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
                      child: const MyTexts(text: "Update",),
                      onPressed: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => AddRoutePage(
                                  initialLocations: locations,
                                  routeName: routeName,
                                )));
                      },
                    ),
                    TextButton(
                      child: const MyTexts(text: "Show Route"),
                      onPressed: () async {
                        final isOptimized =
                            await RootRoute.Route().isRouteOptimized(routeName);

                        if (!isOptimized) {
                          final shouldOptimize = await _showOptimizeDialog(context);
                          if (shouldOptimize == true) {
                            await _optimizeRoute();
                          } else {
                            // Do not navigate if the user does not want to optimize
                            return;
                          }
                        }
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                          return RoutePage(routeLocations: locations, routeName: routeName);
                        },));
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

  Future<bool?> _showOptimizeDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const MyTexts(text: "Optimize Route", fontSize: 25),
          content: const MyTexts(
            text: 'The route is not optimized. Do you want to optimize it?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const MyTexts(text: "Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const MyTexts(text: "Optimize"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _optimizeRoute() async {
    RouteOptimizer optimizer = RouteOptimizer(
      routeName: routeName,
      locations: locations.map((loc) => LocationModel(
        latitude: loc['latitude'],
        longitude: loc['longitude'],
        country: loc['country'],
        vicinity: loc['vicinity'],
      )).toList(),
    );

    await optimizer.updateRouteWithOptimizedOrder();
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
                Navigator.of(context).pop(false);
              },
              child: const MyTexts(text: "Cancel"),
            ),
            TextButton(
              onPressed: () {
                onDelete();
                Navigator.of(context).pop(true);
              },
              child: const MyTexts(text: "Delete"),
            ),
          ],
        );
      },
    );
  }
}
