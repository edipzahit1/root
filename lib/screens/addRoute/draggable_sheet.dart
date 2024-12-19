import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:root/models/location.dart';
import 'package:root/preferences/buttons.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DraggableSheet extends StatefulWidget {
  final List<LocationModel>? initialLocations;
  final String routeName;
  final Function(LocationModel) onLocationAdded;
  final Function(LocationModel) onLocationDeleted;

  const DraggableSheet({
    Key? key,
    this.initialLocations,
    required this.routeName,
    required this.onLocationAdded,
    required this.onLocationDeleted
  }) : super(key: key);

  @override
  DraggableSheetState createState() => DraggableSheetState();
}

class DraggableSheetState extends State<DraggableSheet>
    with SingleTickerProviderStateMixin {
  List<LocationModel> selectedLocations = [];
  List<LocationModel> searchedLocations = [];
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool _isBoxOpen = false;
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  bool _showPopup = false; 

  @override
  void initState() {
    super.initState();
    selectedLocations = widget.initialLocations ?? [];

    _controller =
        AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _offsetAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0))
            .animate(_controller);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 2000), () {
      if (query.isNotEmpty) {
        performSearch(query);
      } else {
        setState(() {
          searchedLocations.clear();
        });
      }
    });
  }

  Future<void> performSearch(String query) async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      String url =
          "https://maps.googleapis.com/maps/api/place/nearbysearch/json?keyword=$query&location=${position.latitude},${position.longitude}&radius=30000&key=${dotenv.env['MAPS_API_KEY']}";
      var response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        Map<String, dynamic> data = jsonDecode(response.body);
        List<dynamic> results = data["results"];

        setState(() {
          searchedLocations = results.map((result) {
            return LocationModel.fromMap({
              'latitude': result['geometry']['location']['lat'],
              'longitude': result['geometry']['location']['lng'],
              'vicinity': result['vicinity'],
              'country': result['plus_code']['compound_code'].split(' ').last,
            });
          }).toList();
        });
      } else {
        print("Failed to fetch search results.");
      }
    } catch (e) {
      print("Failed to perform search: $e");
    }
  }

  void _addLocation(LocationModel location) {
    setState(() {
      selectedLocations.add(location);
      searchedLocations.remove(location);
      _showTemporaryPopup();
    });
  }

  void _removeLocation(LocationModel location) {
    setState(() {
      selectedLocations.remove(location);
    });
    widget.onLocationDeleted(location);
  }

  void _toggleBox() {
    setState(() {
      if (_isBoxOpen) {
        _controller.reverse();
      } else {
        _controller.forward();
      }
      _isBoxOpen = !_isBoxOpen;
    });
  }

  void _showTemporaryPopup() {
    setState(() {
      _showPopup = true;
    });

    Timer(const Duration(seconds: 2), () {
      setState(() {
        _showPopup = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PopScope(
          onPopInvoked: (didPop) {
            selectedLocations.clear();
          },
          child: DraggableScrollableSheet(
            snap: true,
            snapSizes: const [0.2, 0.5, 0.8],
            initialChildSize: 0.2,
            maxChildSize: 0.8,
            minChildSize: 0.2,
            builder: (BuildContext context, ScrollController scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.horizontal(
                      left: Radius.circular(8), right: Radius.circular(8)),
                  gradient: LinearGradient(
                    colors: [AppColors.level_2, AppColors.level_3],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search for locations',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: AppColors.level_5,
                        ),
                      ),
                    ),
                    if (searchedLocations.isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Text('Search Results',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    for (var location in searchedLocations)
                      CardWidget(
                        icon: Icons.add_location,
                        address: location.vicinity,
                        country: location.country,
                        latitude: location.latitude.toString(),
                        longitude: location.longitude.toString(),
                        onTap: () => _addLocation(location),
                      ),
                  ],
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 0,
          right: 0,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                backgroundColor: AppColors.level_5,
                foregroundColor: AppColors.level_1,
                mini: true,
                onPressed: _toggleBox,
                heroTag: 'toggleBoxButton',
                child:
                    Icon(_isBoxOpen ? Icons.arrow_forward : Icons.arrow_back),
              ),
              SlideTransition(
                position: _offsetAnimation,
                child: Container(
                  width: 290,
                  height: 300, // Adjust as needed
                  decoration: const BoxDecoration(
                    color: AppColors.level_5,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      bottomLeft: Radius.circular(10),
                    ),
                  ),
                  child: ListView(
                    children: selectedLocations
                        .map((location) => CardWidget(
                              icon: Icons.location_on,
                              address: location.vicinity,
                              country: location.country,
                              latitude: location.latitude.toString(),
                              longitude: location.longitude.toString(),
                              onTap: () => _removeLocation(location),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_showPopup)
          Positioned(
            top: 80,
            right: 0,
            child: SlideTransition(
              position: _offsetAnimation,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Location added!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}

class CardWidget extends StatelessWidget {
  final IconData icon;
  final String address;
  final String country;
  final String latitude;
  final String longitude;
  final VoidCallback onTap;

  const CardWidget({
    Key? key,
    required this.icon,
    required this.address,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 70,
        child: Card(
          elevation: 8.0,
          child: Container(
            decoration: const BoxDecoration(color: AppColors.level_5),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 8.0),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(width: 1.0, color: AppColors.level_1),
                      ),
                    ),
                    child: Icon(icon, color: AppColors.level_1),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          country,
                          style: const TextStyle(color: Colors.black87),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          address,
                          style: const TextStyle(
                            color: AppColors.level_1,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Montserrat",
                            fontSize: 15,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onTap,
                    icon: const Icon(Icons.delete_outline_sharp,
                        color: AppColors.level_1, size: 30.0),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}