import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:root/main/main.dart';

class Route {
  User? user;
  final String name = "";
  DateTime? date = DateTime.now();
  final List<Map<String, String>> locations = [];

  Future<void> addRoute(
      {required String routeName,
      DateTime? date,
      List<Map<String, double>>? locations}) async {
    try {
      List<Map<String, dynamic>> convertedLocations =
          _convertLocations(locations ?? []);
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(globalUser!.uid)
          .collection('routes')
          .add({
        'routeName': routeName,
        'date': date,
        'locations': convertedLocations,
      });
      print('Route added successfully for user ${globalUser!.uid}');
    } catch (e) {
      print('Error adding route for user ${globalUser!.uid}: $e');
    }
  }

  List<Map<String, dynamic>> _convertLocations(
    List<Map<String, double>> locations) { // Change the type to accept latitude and longitude as double
  return locations
      .map((location) => {
            'latitude': location['latitude'],
            'longitude': location['longitude'],
          })
      .toList();
}

  Future<void> deleteRoute({required String routeName}) async {
    try {
      // Query the routes collection to find the document ID for the route with the given name
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(globalUser!.uid)
          .collection('routes')
          .where('routeName', isEqualTo: routeName)
          .get();

      // Check if any documents match the query
      if (querySnapshot.docs.isNotEmpty) {
        // Get the first document (assuming route names are unique) and delete it
        final documentId = querySnapshot.docs.first.id;
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(globalUser!.uid)
            .collection('routes')
            .doc(documentId)
            .delete();
        print('Route deleted successfully');
      } else {
        print('Route with name $routeName not found');
      }
    } catch (e) {
      print('Error deleting route: $e');
    }
  }

  Future<void> addLocationToRoute({
    required String routeName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      // Get the reference to the route document based on the route name
      final routeQuery = await FirebaseFirestore.instance
          .collection('Users')
          .doc(globalUser!.uid)
          .collection('routes')
          .where('routeName', isEqualTo: routeName)
          .get();

      // Check if any documents match the query
      if (routeQuery.docs.isNotEmpty) {
        // Get the document ID of the route
        final routeDocId = routeQuery.docs.first.id;

        // Add the new location data to the 'locations' subcollection of the route
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(globalUser!.uid)
            .collection('routes')
            .doc(routeDocId)
            .collection('locations')
            .add({
          'latitude': latitude,
          'longitude': longitude,
        });

        print('Location added to route $routeName');
      } else {
        print('Route with name $routeName not found');
      }
    } catch (e) {
      print('Error adding location to route: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> getRoutesStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('routes')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            // Convert Timestamp to DateTime
            final dateTime = (data['date'] as Timestamp).toDate();
            // Replace the 'date' field with the converted DateTime object
            data['date'] = dateTime;
            return data;
          }).toList(),
        );
  }
}
