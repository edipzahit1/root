import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/mapStyle.dart';
import 'package:root/screens/addRoute/locationPermissionHandler.dart';

class BuildMap extends StatefulWidget {
  final List<Map<String, double>>? locations;
  final List<Map<String, double>>? orderedRoute;
  const BuildMap({Key? key, this.locations, this.orderedRoute})
      : super(key: key);

  @override
  State<BuildMap> createState() => _BuildMapState();
}

class _BuildMapState extends State<BuildMap> {
  final places_API_KEY = dotenv.env["PLACES_API_KEY"];

  late CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37, 122), 
    zoom: 10, 
  );
  late GoogleMapController googleMapController;
  late GooglePlace googlePlace;
  String? _mapStyle;
  final Set<Marker> _markers = {};

  late LocationPermissionHandler _permissionHandler;

  @override
  void initState() {
    super.initState();
    _mapStyle = jsonEncode(myMapStyle);
    _permissionHandler = LocationPermissionHandler(context: context);
    _getInitialPosition();
  }

  @override
  void dispose() {
    _permissionHandler.dispose();
    super.dispose();
  }

  Future<void> _getInitialPosition() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(position.latitude, position.longitude),
          ),
        );

        initialCameraPosition = CameraPosition(
          target: LatLng(position.latitude, position.longitude),
          zoom: 10,
        );
      });
    } catch (e) {
      print('Error getting initial position: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          markers: _markers,
          onLongPress: (LatLng latLng) async {
            setState(() {
              _onMapLongPress(latLng);
              _markers.add(
                Marker(
                  markerId: MarkerId(latLng.toString()),
                  position: latLng,
                  infoWindow: const InfoWindow(
                    title: 'Long Pressed Location',
                  ),
                ),
              );
            });
          },
          compassEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            googleMapController = controller;
            googleMapController.setMapStyle(_mapStyle);
          },
          initialCameraPosition: initialCameraPosition,
        ),
        buildMyLocationButton(),
      ],
    );
  }

  Widget buildMyLocationButton() {
    return Padding(
      padding: const EdgeInsets.all(4.5),
      child: FloatingActionButton(
        backgroundColor: AppColors.level_5,
        mini: true,
        onPressed: () async {
          Position position = await _determinePosition();

          googleMapController.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude),
                  zoom: 14)));

          _markers.add(Marker(
              markerId: const MarkerId('currentLocation'),
              position: LatLng(position.latitude, position.longitude)));

          setState(() {});
        },
        child: const Icon(Icons.my_location, color: AppColors.level_1),
      ),
    );
  }

  Future<void> _onMapLongPress(LatLng latLng) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latLng.latitude, latLng.longitude);

    if (placemarks.isNotEmpty) {
      Placemark firstPlacemark = placemarks[0];

      print('Name: ${firstPlacemark.name}');
      print('Street: ${firstPlacemark.street}');
      print('City: ${firstPlacemark.locality}');
      print('Postal Code: ${firstPlacemark.postalCode}');
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return Future.error("Location permission denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }
}
