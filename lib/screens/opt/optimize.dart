import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:root/models/location.dart';
import 'package:root/models/route.dart' as RootRoute;

class RouteOptimizer {
  final String routeName;
  final List<LocationModel> locations;

  RouteOptimizer({required this.routeName, required this.locations});

  Future<List<int>> getOptimizedOrder() async {
    try {
      List<List<int>> distanceMatrix = await getDistanceMatrix();
      // Prepare data for the HTTP POST request
      Map<String, dynamic> jsonData = {
        "distanceMatrix": distanceMatrix,
      };

      // Additional parameters
      Map<String, dynamic> params = {
        'EVOLUTION_TIME': 500,
        'NUMBER_OF_CITIES': distanceMatrix.length,
        'POPULATION_SIZE': 100,
        'CROSSOVER_PROBABILITY': 0.95,
        'MUTATION_PROBABILITY': 0.05,
      };

      // Combine parameters and JSON data
      jsonData.addAll(params);

      // Send POST request
      const  url =
          'https://europe-west6-root-415721.cloudfunctions.net/function-3';
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(jsonData),
      );

      if (response.statusCode == 200) {
        // Extract the list of integers from the response body
        List<int> solution = List<int>.from(json.decode(response.body));

        return solution;
      } else {
        return [];
      }
    } catch (e) {
      print('Failed to load distance matrix: $e');
      return [];
    }
  }

  Future<List<List<int>>> getDistanceMatrix() async {
    final String apiKey = dotenv.env['MAPS_API_KEY']!;
    List<String> origins = locations
        .map((location) => '${location.latitude},${location.longitude}')
        .toList();
    List<String> destinations = origins;

    final String url =
        'https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origins.join('|')}&destinations=${destinations.join('|')}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> rows = data['rows'];

      List<List<int>> distanceMatrix = [];

      for (var row in rows) {
        List<int> rowDistances = [];
        for (var element in row['elements']) {
          rowDistances.add(element['distance']['value']);
        }
        distanceMatrix.add(rowDistances);
      }

      return distanceMatrix;
    } else {
      print('Failed to fetch distance matrix: ${response.statusCode}');
      print('Response body: ${response.body}');
      return [];
    }
  }

  Future<void> updateRouteWithOptimizedOrder() async {
    List<int> optimizedOrder = await getOptimizedOrder();

    if (optimizedOrder.isNotEmpty) {
      List<Map<String, dynamic>> optimizedLocations =
          optimizedOrder.map((index) => locations[index].toMap()).toList();

      // Update the route in Firestore
      await RootRoute.Route().updateRoute(
        routeName: routeName,
        date: DateTime.now(),
        locations: optimizedLocations,
      );

      // Generate and update the navigation URL
      Uri navigationUri = generateNavigationUri(optimizedLocations);
      await RootRoute.Route()
          .updateNavigationUrl(routeName, navigationUri.toString());
    }
  }

  Uri generateNavigationUri(List<Map<String, dynamic>> optimizedLocations) {
    final origin = optimizedLocations.first;
    final destination = optimizedLocations.last;

    return Uri.parse(
        'https://www.google.com/maps/dir/?api=1&origin=${origin['latitude']},${origin['longitude']}&destination=${destination['latitude']},${destination['longitude']}&travelmode=driving');
  }
}
