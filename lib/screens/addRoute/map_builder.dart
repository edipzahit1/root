import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:root/models/location.dart';
import 'package:root/preferences/buttons.dart';
import 'package:root/preferences/map_style.dart';
import 'package:root/screens/addRoute/location_permission_handler.dart';
import 'package:http/http.dart' as http;

class BuildMap extends StatefulWidget {
  final List<LocationModel>? locations;
  final List<Map<String, double>>? orderedRoute;
  final Function(LocationModel) onLocationAdded;
  const BuildMap(
      {Key? key,
      this.locations,
      this.orderedRoute,
      required this.onLocationAdded,})
      : super(key: key);

  @override
  State<BuildMap> createState() => _BuildMapState();
}

class _BuildMapState extends State<BuildMap> {
  late CameraPosition initialCameraPosition = const CameraPosition(
    target: LatLng(37, 122),
    zoom: 10,
  );
  late GoogleMapController googleMapController;
  String? _mapStyle;
  final Set<Marker> _markers = {};

  late LocationPermissionHandler _permissionHandler;

  @override
  void initState() {
    super.initState();
    _mapStyle = jsonEncode(myMapStyle);
    _permissionHandler = LocationPermissionHandler(context: context);

    widget.locations?.forEach((location) {
      addMarker(location);
    });

    _getInitialPosition();
  }

  @override
  void dispose() {
    _permissionHandler.dispose();
    super.dispose();
  }

  void addMarker(LocationModel location) async {
    setState(() {
      _markers.add(Marker(
        markerId: MarkerId("marker_${location.latitude}_${location.longitude}"),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(title: location.vicinity, snippet: location.country),
      ));
    });
  }

  void removeMarker(LocationModel location) {
    setState(() {
      _markers.removeWhere((marker) =>
          marker.markerId == MarkerId("marker_${location.latitude}_${location.longitude}"));
    });
  }

  Future<void> _getInitialPosition() async {
    try {
      Position position = await _determinePosition();
      setState(() {
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
          myLocationButtonEnabled: false,
          myLocationEnabled: true,
          markers: _markers.toSet(),
          onLongPress: (LatLng latLng) async {
            _onMapLongPress(latLng);
          },
          compassEnabled: true,
          zoomControlsEnabled: false,
          onMapCreated: (controller) {
            googleMapController = controller;
            googleMapController.setMapStyle(_mapStyle);
            _moveCameraToCurrentUserLocation();
          },
          initialCameraPosition: initialCameraPosition,
        ),
        buildMyLocationButton(),
      ],
    );
  }

  Future<void> _moveCameraToCurrentUserLocation() async {
    var position = await _determinePosition();
    googleMapController.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0 // Adjust zoom level as necessary
            )));
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

  void _onMapLongPress(LatLng latLng) async {
    try {
      Map<String, String> address = await getAddressFromLatLng(latLng.latitude, latLng.longitude);
      LocationModel location = LocationModel(
        latitude: latLng.latitude,
        longitude: latLng.longitude,
        vicinity: address['vicinity'] ?? 'Unknown Vicinity',
        country: address['country'] ?? 'Unknown Country',
      );

      addMarker(location);
      widget.onLocationAdded(location);
    } catch (e) {
      print('Failed to get address: $e');
    }
  }

  Future<Map<String, String>> getAddressFromLatLng(double lat, double lng) async {
    final apiKey = dotenv.env['MAPS_API_KEY'];
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        final results = data['results'][0];
        String country = '';
        String vicinity = '';

        List addressComponents = results['address_components'];

        for (var component in addressComponents) {
          List types = component['types'];
          if (types.contains('country')) {
            country = component['long_name'];
          }
          if (types.contains('sublocality') || types.contains('locality')) {
            vicinity = component['long_name'];
          }
        }

        return {'vicinity': vicinity, 'country': country};
      } else {
        throw Exception('Failed to load address');
      }
    } else {
      throw Exception('Failed to load address');
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