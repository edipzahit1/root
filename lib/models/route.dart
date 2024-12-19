import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:root/main/main.dart';

class Route {
  User? user;
  final String name = "";
  DateTime? date = DateTime.now();
  final List<Map<String, dynamic>> locations = [];

  Future<void> addRoute({
    required String routeName,
    DateTime? date,
    List<Map<String, double>>? locations,
    String? vicinity,
    String? country,
  }) async {
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
        'isOptimized': false,
        'navigationUrl': '',
      });
      print('Route added successfully for user ${globalUser!.uid}');
    } catch (e) {
      print('Error adding route for user ${globalUser!.uid}: $e');
    }
  }

  List<Map<String, dynamic>> _convertLocations(
      List<Map<String, double>> locations) {
    return locations
        .map((location) => {
              'latitude': location['latitude'] as double,
              'longitude': location['longitude'] as double,
            })
        .toList();
  }

  Future<void> deleteRoute({required String routeName}) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(globalUser!.uid)
        .collection('routes')
        .where('routeName', isEqualTo: routeName)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
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
  }

  Future<void> clearLocationsInRoute({required String routeName}) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(globalUser!.uid)
        .collection('routes')
        .where('routeName', isEqualTo: routeName)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      final documentId = querySnapshot.docs.first.id;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(globalUser!.uid)
          .collection('routes')
          .doc(documentId)
          .update({'locations': []});
      print('Locations cleared successfully in route $routeName');
    } else {
      print('Route with name $routeName not found');
    }
  }

  Future<void> addLocationToRoute({
    required String routeName,
    required double latitude,
    required double longitude,
    required String vicinity,
    required String country,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final userRoutesRef =
        firestore.collection('Users').doc(globalUser!.uid).collection('routes');
    final querySnapshot =
        await userRoutesRef.where('routeName', isEqualTo: routeName).get();
    if (querySnapshot.docs.isNotEmpty) {
      final DocumentReference routeRef = querySnapshot.docs.first.reference;
      firestore.runTransaction((transaction) async {
        final routeSnapshot = await transaction.get(routeRef);
        if (!routeSnapshot.exists) {
          throw Exception("Route does not exist anymore.");
        }
        transaction.update(routeRef, {
          'locations': FieldValue.arrayUnion([
            {
              'latitude': latitude,
              'longitude': longitude,
              'vicinity': vicinity,
              'country': country,
            }
          ]),
        });
      }).then((result) {
        print(
            'Location added to route $routeName with vicinity $vicinity and country $country');
      }).catchError((error) {
        print('Error adding location to route: $error');
      });
    } else {
      print('Route with name $routeName not found');
    }
  }

  Future<void> updateRoute({
    required String routeName,
    required DateTime date,
    required List<Map<String, dynamic>> locations,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final routesRef =
        firestore.collection('Users').doc(globalUser!.uid).collection('routes');

    try {
      // Get the existing route document
      final querySnapshot =
          await routesRef.where('routeName', isEqualTo: routeName).get();
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;

        // Clear existing locations
        await routesRef.doc(documentId).update({'locations': []});

        // Add new locations
        for (var location in locations) {
          await routesRef.doc(documentId).update({
            'locations': FieldValue.arrayUnion([location])
          });
        }

        print('Route updated successfully.');
      } else {
        print('Route does not exist.');
      }
    } catch (e) {
      print('Failed to update route: $e');
    }
  }

  Future<void> updateNavigationUrl(String routeName, String url) async {
    final firestore = FirebaseFirestore.instance;
    final routesRef =
        firestore.collection('Users').doc(globalUser!.uid).collection('routes');

    try {
      final querySnapshot =
          await routesRef.where('routeName', isEqualTo: routeName).get();
      if (querySnapshot.docs.isNotEmpty) {
        final documentId = querySnapshot.docs.first.id;
        await routesRef.doc(documentId).update({'navigationUrl': url});
        await routesRef.doc(documentId).update({'isOptimized': true});
        print('Navigation URL updated successfully.');
      } else {
        print('Route does not exist.');
      }
    } catch (e) {
      print('Failed to update navigation URL: $e');
    }
  }

  Future<bool> isRouteOptimized(String routeName) async {
    final firestore = FirebaseFirestore.instance;
    final routesRef =
        firestore.collection('Users').doc(globalUser!.uid).collection('routes');

    try {
      final querySnapshot =
          await routesRef.where('routeName', isEqualTo: routeName).get();
      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        return data['isOptimized'] ?? false;
      } else {
        print('Route does not exist.');
      }
    } catch (e) {
      print('Failed to check if route is optimized: $e');
    }

    return false;
  }

  Stream<List<Map<String, dynamic>>> getRoutesStream(String userId) {
    return FirebaseFirestore.instance
        .collection('Users')
        .doc(userId)
        .collection('routes')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data();

        // Convert the date field from Timestamp to DateTime, if it exists
        data['date'] =
            data['date'] != null ? (data['date'] as Timestamp).toDate() : null;

        // Convert the locations field, if it exists
        if (data['locations'] != null) {
          data['locations'] =
              (data['locations'] as List<dynamic>).map((location) {
            return {
              'country': location['country'] as String,
              'latitude': (location['latitude'] is double)
                  ? location['latitude']
                  : double.tryParse(location['latitude'].toString()) ?? 0.0,
              'longitude': (location['longitude'] is double)
                  ? location['longitude']
                  : double.tryParse(location['longitude'].toString()) ?? 0.0,
              'vicinity': location['vicinity'] as String
            };
          }).toList();
        }

        print("DATAAA");
        print(data);
        return data;
      }).toList();
    });
  }
}
