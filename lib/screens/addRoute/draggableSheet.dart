import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';

class DraggableSheet extends StatefulWidget {
  const DraggableSheet({super.key});

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  List<String> selectedformattedAddresses = [];
  List<String> formattedAddresses = [];

  String urlNearbySearch =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
  String urlPlaceDetails =
      "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address";

  Map<String, dynamic> locations = {};
  List<dynamic> placeIds = [];

  final places_API_KEY = dotenv.env["PLACES_API_KEY"];

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      snapSizes: [0.2, 0.5, 0.9],
      initialChildSize: 0.2,
      maxChildSize: 0.9,
      minChildSize: 0.2,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.level_2, AppColors.level_3],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: ListView.builder(
            physics: ClampingScrollPhysics(),
            controller: scrollController,
            itemCount: formattedAddresses.length +
                selectedformattedAddresses.length +
                1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                      width: 50,
                      child: Divider(thickness: 5),
                    ),
                    Container(
                      height: 50,
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: TextField(
                        textAlign: TextAlign.left,
                        controller: _searchController,
                        onChanged: (value) {
                          if (_debounce?.isActive ?? false) _debounce!.cancel();
                          _debounce =
                              Timer(const Duration(milliseconds: 2000), () {
                            if (value.isNotEmpty) {
                              nearbySearch(value: value);
                            } else {
                              setState(() {
                                formattedAddresses.clear();
                              });
                            }
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: AppColors.level_5,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (index <= selectedformattedAddresses.length) {
                return ListTile(
                  title: Text(selectedformattedAddresses[index - 1]),
                );
              } else {
                int formattedAddressesIndex =
                    index - selectedformattedAddresses.length - 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedformattedAddresses
                          .add(formattedAddresses[formattedAddressesIndex]);
                    });
                  },
                  child: Container(
                    height: 50,
                    color: Colors.transparent,
                    child: Row(
                      children: [
                        Icon(Icons.location_pin, color: Colors.black),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            formattedAddresses[formattedAddressesIndex],
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
            },
          ),
        );
      },
    );
  }

  Future<void> nearbySearch({required String value}) async {
    try {
      var result_nearby_search = await http.get(Uri.parse(
          "${urlNearbySearch}keyword=${value}&location=40.859400%2C29.378540&radius=30000&key=${places_API_KEY}"));
      if (result_nearby_search.statusCode == 200) {
        locations = jsonDecode(result_nearby_search.body);
        List<dynamic> results = locations["results"];
        placeIds = results.map((result) => result["place_id"]).toList();
      }
      int count = 0;
      for (String placeId in placeIds) {
        if (count > 1) {
          break;
        }
        var result_place_details = await http.get(Uri.parse(
            "${urlPlaceDetails}&place_id=${placeId}&key=${places_API_KEY}"));
        if (result_place_details.statusCode == 200) {
          Map<String, dynamic> placeDetails =
              jsonDecode(result_place_details.body);
          String formattedAddress = placeDetails["result"]["formatted_address"];

          setState(() {
            formattedAddresses.add(formattedAddress);
          });
        } else {
          print("Failed to fetch details for place ID: ${placeId}");
        }
        count++;
      }
    } catch (e) {
      print("Error occurred while getting locations. $e");
    }
  }
}
