import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/map_style.dart';
import 'package:root/preferences/my_texts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:root/models/route.dart' as RootRoute;

class RoutePage extends StatefulWidget {
  final List<Map<String, dynamic>> routeLocations;
  final String routeName;

  const RoutePage({Key? key, required this.routeLocations, required this.routeName})
      : super(key: key);

  @override
  RoutePageState createState() => RoutePageState();
}

class RoutePageState extends State<RoutePage> {
  late GoogleMapController googleMapController;
  final Set<Polyline> _polylines = {};
  final Set<Marker> _markers = {};
  String? _mapStyle;
  BitmapDescriptor? customMarker;

  @override
  void initState() {
    super.initState();
    _mapStyle = jsonEncode(myMapStyle);
    _loadCustomMarker();
    _setupRoute();
  }

  Future<void> _loadCustomMarker() async {
    customMarker = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(48, 48)),
      'assets/marker.png', // Ensure you have the correct path to your marker image
    );
  }

  Future<void> _setupRoute() async {
    Position currentPosition = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    LatLng currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

    List<Map<String, dynamic>> updatedRouteLocations = List.from(widget.routeLocations);
    if (updatedRouteLocations.isEmpty || 
        updatedRouteLocations.first['latitude'] != currentLatLng.latitude || 
        updatedRouteLocations.first['longitude'] != currentLatLng.longitude) {
      updatedRouteLocations.insert(0, {'latitude': currentLatLng.latitude, 'longitude': currentLatLng.longitude});
    }

    if (updatedRouteLocations.isNotEmpty) {
      for (int i = 0; i < updatedRouteLocations.length - 1; i++) {
        await _getDirections(
          LatLng(updatedRouteLocations[i]['latitude'], updatedRouteLocations[i]['longitude']),
          LatLng(updatedRouteLocations[i + 1]['latitude'], updatedRouteLocations[i + 1]['longitude']),
        );
        _addMarker(LatLng(updatedRouteLocations[i]['latitude'], updatedRouteLocations[i]['longitude']));
      }
      // Add marker for the last location
      _addMarker(LatLng(updatedRouteLocations.last['latitude'], updatedRouteLocations.last['longitude']));
    }
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final String apiKey = dotenv.env['MAPS_API_KEY']!;
    final String url = 'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final String status = data['status'];
      if (status == 'OK') {
        final List<dynamic> route = data['routes'];
        if (route.isNotEmpty) {
          final Map<String, dynamic> leg = route[0]['legs'][0];
          final List<dynamic> steps = leg['steps'];
          final List<LatLng> polylineCoordinates = [];

          for (var step in steps) {
            final lat = step['end_location']['lat'];
            final lng = step['end_location']['lng'];
            polylineCoordinates.add(LatLng(lat, lng));
          }

          _addPolyline(polylineCoordinates);
        }
      } else {
        print('Error: $status');
        // Print detailed error information for debugging
        print('Error message: ${data['error_message']}');
      }
    } else {
      print('Failed to fetch directions: ${response.statusCode}');
      // Print detailed error information for debugging
      print('Response body: ${response.body}');
    }
  }

  void _addPolyline(List<LatLng> polylineCoordinates) {
    setState(() {
      _polylines.add(Polyline(
        polylineId: PolylineId('route_${_polylines.length}'),
        points: polylineCoordinates,
        color: Colors.blue,
        width: 5,
      ));
    });
  }

  void _addMarker(LatLng position) {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId(position.toString()),
        position: position,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueCyan), // Use custom marker if available
      ));
    });
  }

  Future<void> _fitRoute(List<LatLng> routePoints) async {
    double minLat = routePoints.map((p) => p.latitude).reduce((a, b) => a < b ? a : b);
    double maxLat = routePoints.map((p) => p.latitude).reduce((a, b) => a > b ? a : b);
    double minLng = routePoints.map((p) => p.longitude).reduce((a, b) => a < b ? a : b);
    double maxLng = routePoints.map((p) => p.longitude).reduce((a, b) => a > b ? a : b);

    googleMapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0,
      ),
    );
  }

  Future<Uri?> _getNavigationUriAndSave() async {
    if (widget.routeLocations.isNotEmpty) {
      final origin = widget.routeLocations.first;
      final destination = widget.routeLocations.last;

      final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&origin=${origin['latitude']},${origin['longitude']}&destination=${destination['latitude']},${destination['longitude']}&travelmode=driving');

      await RootRoute.Route().updateNavigationUrl(widget.routeName, url.toString());

      return url;
    }
    return null;
  }

  void _startNavigation() async {
    final Uri? navigationUri = await _getNavigationUriAndSave();

    if (navigationUri != null) {
      if (await canLaunchUrl(navigationUri)) {
        await launchUrl(navigationUri);
      } else {
        throw 'Could not launch $navigationUri';
      }
    } else {
      print('Navigation URL is not available.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.level_5,
        title: const MyTexts(
          text: 'Route',
          fontSize: 20,
        ),
      ),
      body: Stack(
        children: [
          GoogleMap(
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            initialCameraPosition: const CameraPosition(
              target: LatLng(37.7749, -122.4194),
              zoom: 10,
            ),
            polylines: _polylines,
            markers: _markers,
            onMapCreated: (controller) {
              googleMapController = controller;
              googleMapController.setMapStyle(_mapStyle);
              if (_polylines.isNotEmpty) {
                _fitRoute(_polylines.first.points);
              }
            },
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: FloatingActionButton(
              onPressed: _startNavigation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.navigation, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
