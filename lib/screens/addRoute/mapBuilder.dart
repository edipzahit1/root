import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
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

  late GoogleMapController? googleMapController;
  late GooglePlace googlePlace;
  String? _mapStyle;
  final Set<Marker> _markers = {};

  late LocationPermissionHandler _permissionHandler;
  late Position _initialPosition;

  @override
  void initState() {
    super.initState();
    _mapStyle = jsonEncode(myMapStyle);
    _permissionHandler = LocationPermissionHandler(context: context);
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _permissionHandler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
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
      zoomControlsEnabled: false,
      myLocationEnabled: true, // Enable current user location display
      myLocationButtonEnabled: true, // Enable My Location button
      onMapCreated: (controller) {
        googleMapController = controller;
        googleMapController!.setMapStyle(_mapStyle);
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(_initialPosition.latitude, _initialPosition.longitude), 
        zoom: 10,
      ),
    );
  }

  Widget buildMyLocationButton() {
    return FloatingActionButton(
      onPressed: () {
        _getCurrentLocation();
      },
      child: Icon(Icons.my_location),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      _initialPosition = await Geolocator.getCurrentPosition();
      if (googleMapController != null) {
        googleMapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target:
                  LatLng(_initialPosition.latitude, _initialPosition.longitude),
              zoom: 15,
            ),
          ),
        );
        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: MarkerId("currentLocation"),
              position:
                  LatLng(_initialPosition.latitude, _initialPosition.longitude),
              infoWindow: InfoWindow(title: 'Current Location'),
            ),
          );
        });
      }
    } catch (e) {
      print('Error getting current location: $e');
    }
  }

  /*Will be called place details*/
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
    ;
  }
}
