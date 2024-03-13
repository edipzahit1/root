import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:root/preferences/mapStyle.dart';

class BuildMap extends StatefulWidget {
  const BuildMap({super.key});

  @override
  State<BuildMap> createState() => _BuildMapState();
}

class _BuildMapState extends State<BuildMap> {
  late GoogleMapController? googleMapController;
  late GooglePlace googlePlace;
  String? _mapStyle;

  @override
  void initState() {
    super.initState();
    _mapStyle = jsonEncode(myMapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      zoomControlsEnabled: false,
      onMapCreated: (controller) {
        googleMapController = controller;
        googleMapController!.setMapStyle(_mapStyle);
      },
      initialCameraPosition: CameraPosition(
        target: LatLng(42, -122),
      ),
    );
  }

  Widget buildMyLocationButton() {
    return FloatingActionButton.extended(
        shape: CircleBorder(
            side: BorderSide(
          width: 3,
          color: Color.fromARGB(255, 56, 68, 113),
        )),
        onPressed: () async {
          Position position = await determinePosition();

          //returning null from mapcontroller we will get there
          googleMapController!.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(
                  target: LatLng(position.latitude, position.longitude))));

          setState(() {});
        },
        label: Icon(Icons.my_location_rounded));
  }

  Future<Position> determinePosition() async {
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
