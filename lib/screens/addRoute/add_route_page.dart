import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:root/models/location.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/my_texts.dart';
import 'package:root/screens/addRoute/draggable_sheet.dart';
import 'package:root/screens/addRoute/map_builder.dart';
import 'package:root/screens/opt/optimize.dart';
import 'package:root/screens/showRouteAndNav/show_route.dart';
import 'package:root/models/route.dart' as RootRoute;

class AddRoutePage extends StatefulWidget {
  final List<Map<String, dynamic>>? initialLocations;
  final String routeName;
  const AddRoutePage({Key? key, this.initialLocations, required this.routeName})
      : super(key: key);

  @override
  State<AddRoutePage> createState() => _AddRoutePageState();
}

class _AddRoutePageState extends State<AddRoutePage> {
  List<Map<String, dynamic>>? orderedRoute;
  List<LocationModel> locations = [];

  @override
  void initState() {
    super.initState();
    print("Initializing locations...");

    // Assuming widget.initialLocations might have mixed data types
    locations = (widget.initialLocations ?? []).map((location) {
      return LocationModel(
        latitude: double.tryParse(location['latitude'].toString()) ?? 0.0,
        longitude: double.tryParse(location['longitude'].toString()) ?? 0.0,
        country: location['country'] as String? ?? 'Unknown Country',
        vicinity: location['vicinity'] as String? ?? 'Unknown Vicinity',
      );
    }).toList();

    print("Locations initialized with additional fields.");
  }

  void optimizeRoute(List<LocationModel> locations) async {
    try {
      // Get the current location
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Create a LocationModel for the current location
      LocationModel currentLocation = LocationModel(
        latitude: currentPosition.latitude,
        longitude: currentPosition.longitude,
        vicinity: 'Current Location',
        country: '',
      );

      // Add current location to the start and end of the list
      if (locations.isEmpty || locations[0].latitude != currentLocation.latitude || locations[0].longitude != currentLocation.longitude) {
        locations.insert(0, currentLocation);
      }

      RouteOptimizer optimizer = RouteOptimizer(
        routeName: widget.routeName,
        locations: locations,
      );

      await optimizer.updateRouteWithOptimizedOrder();

      // Convert optimizedLocations to a List<Map<String, dynamic>> with only lat and lng
      List<Map<String, dynamic>> routeLocations =
          locations.map((location) {
        return {
          'latitude': location.latitude,
          'longitude': location.longitude,
        };
      }).toList();

      // Update the state and UI with the new order
      setState(() {
        locations = locations;
      });

      // Navigate to RoutePage with the required data
      print("Navigating to RoutePage...");
      Navigator.of(context).push(MaterialPageRoute(builder: (context) {
        return RoutePage(routeLocations: routeLocations, routeName: widget.routeName);
      }));

      // Hide waiting dialog
    } catch (e) {
      print('Failed to optimize route: $e');
    }
  }

  Future<void> saveCurrentRoute() async {
    try {
      final routeService = RootRoute.Route();
      await routeService.updateRoute(
        routeName: widget.routeName,
        date: DateTime.now(), 
        locations: locations.map((location) => location.toMap()).toList(),
      );
    } catch (e) {
      print("Failed to save route: $e");
    }
  }

  void addLocation(LocationModel location) {
    setState(() {
      locations.add(location);
    });
  }

  void deleteLocation(LocationModel location) {
    setState(() {
      locations.remove(location);
    });
  }

  void showWaitingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 20),
                Text("Optimizing route..."),
              ],
            ),
          ),
        );
      },
    );
  }

  void hideWaitingDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.level_1,
        leading: Container(
          decoration: BoxDecoration(
            color: AppColors.level_5,
            borderRadius: BorderRadius.circular(10),
          ),
          child: BackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: Row(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.route,
                  color: AppColors.level_1), // Icon for the button
              label: const MyTexts(
                text: 'Start Opt',
                fontSize: 15,
              ),
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(AppColors.level_5),
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
                optimizeRoute(locations);
              },
            ),
            const SizedBox(width: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.save,
                  color: AppColors.level_1),
              label: const MyTexts(
                text: 'Save Route',
                fontSize: 13,
              ),
              style: ButtonStyle(
                backgroundColor: const WidgetStatePropertyAll(AppColors.level_5),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
                elevation: const WidgetStatePropertyAll(4),
                shape: WidgetStatePropertyAll<RoundedRectangleBorder>(
                    RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                )),
                padding: const WidgetStatePropertyAll(
                    EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
              ),
              onPressed: saveCurrentRoute,
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          BuildMap(
            locations: locations,
            onLocationAdded: (location) {
              addLocation(location);
            },
          ),
          DraggableSheet(
            initialLocations: locations,
            onLocationAdded: (location) {
              addLocation(location);
            },
            onLocationDeleted: (location) {
              deleteLocation(location);
            },
            routeName: widget.routeName,
          ),
        ],
      ),
    );
  }
}
