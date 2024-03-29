import 'dart:async';
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:root/preferences/buttons.dart';

List<String> selectedCountrys = [];
List<String> selectedFormattedAddresses = [];

List<String> formattedAddresses = [];
List<String> countrys = [];

String urlNearbySearch =
    "https://maps.googleapis.com/maps/api/place/nearbysearch/json?";
String urlPlaceDetails =
    "https://maps.googleapis.com/maps/api/place/details/json?fields=formatted_address,address_components";

class DraggableSheet extends StatefulWidget {
  const DraggableSheet({super.key});

  @override
  State<DraggableSheet> createState() => _DraggableSheetState();
}

class _DraggableSheetState extends State<DraggableSheet> {
  Map<String, dynamic> locations = {};
  List<dynamic> placeIds = [];

  final places_API_KEY = dotenv.env["PLACES_API_KEY"];

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      snap: true,
      snapSizes: const [0.2, 0.5, 0.9],
      initialChildSize: 0.2,
      maxChildSize: 0.9,
      minChildSize: 0.2,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [AppColors.level_2, AppColors.level_3],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter)),
          child: ListView.builder(
            physics: const ClampingScrollPhysics(),
            controller: scrollController,
            itemCount: formattedAddresses.length +
                selectedFormattedAddresses.length +
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
                      padding: const EdgeInsets.only(left: 10, right: 10),
                      child: TextField(
                        cursorHeight: 20,
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
                          border: UnderlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                    ),
                  ],
                );
              } else if (index <= selectedFormattedAddresses.length) {
                return Dismissible(
                    key: Key(selectedFormattedAddresses[index - 1]),
                    direction: DismissDirection.endToStart,
                    onDismissed: (direction) {
                      setState(() {
                        selectedFormattedAddresses.removeAt(index - 1);
                        countrys.removeAt(index - 1);
                      });
                    },
                    background: Container(
                      color: Colors.red,
                      child: const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Icon(
                            Icons.delete,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    child: CardWidget(
                      icon: Icons.autorenew,
                      address: selectedFormattedAddresses[index - 1],
                      country: countrys[index - 1],
                      onTap: () {
                        setState(() {
                          selectedFormattedAddresses.removeAt(index - 1);
                          countrys.removeAt(index - 1);
                        });
                      },
                    ));
              } else {
                int Index = index - selectedFormattedAddresses.length - 1;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCountrys.add(countrys[Index]);
                      selectedFormattedAddresses.add(formattedAddresses[Index]);
                    });
                  },
                  child: CardWidget(
                    address: formattedAddresses[Index],
                    country: countrys[Index],
                    icon: Icons.add,
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
        int count = 0;
        countrys.clear();
        formattedAddresses.clear();
        for (String placeId in placeIds) {
          if (count > 3) {
            break;
          }
          var result_place_details = await http.get(Uri.parse(
              "${urlPlaceDetails}&place_id=${placeId}&key=${places_API_KEY}"));
          if (result_place_details.statusCode == 200) {
            Map<String, dynamic> placeDetails =
                jsonDecode(result_place_details.body);
            String formattedAddress =
                placeDetails["result"]["formatted_address"];
            List<dynamic> addressComponents =
                placeDetails["result"]["address_components"];
            String country = "";
            for (var component in addressComponents) {
              List<String> types = List<String>.from(component["types"]);
              if (types.contains("country")) {
                country = component["long_name"];
              }
            }
            setState(() {
              countrys.add(country);
              formattedAddresses.add(formattedAddress);
            });
          } else {
            print("Failed to fetch details for place ID: ${placeId}");
          }
          count++;
        }
      } else {
        print("Failed to fetch nearby locations");
      }
    } catch (e) {
      print("Error occurred while getting locations. $e");
    }
  }
}

class CardWidget extends StatelessWidget {
  final IconData icon;
  final String address;
  final String country;
  final VoidCallback? onTap;

  const CardWidget({
    Key? key,
    required this.icon,
    required this.address,
    required this.country,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Card(
        elevation: 8.0,
        child: Container(
          decoration: const BoxDecoration(color: AppColors.level_5),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.only(right: 8.0),
                  decoration: const BoxDecoration(
                    border: Border(
                      right: BorderSide(
                        width: 1.0,
                        color: AppColors.level_1,
                      ),
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
                        style: TextStyle(color: Colors.black87),
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
                  icon: Icon(Icons.delete_outline_sharp,
                      color: AppColors.level_1, size: 30.0),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
