class LocationModel {
  final double latitude;
  final double longitude;
  final String vicinity;
  final String country;

  LocationModel({
    required this.latitude,
    required this.longitude,
    required this.vicinity,
    required this.country,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      latitude: map['latitude'],
      longitude: map['longitude'],
      vicinity: map['vicinity'] ?? 'Unknown Vicinity',
      country: map['country'] ?? 'Unknown Country',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'vicinity': vicinity,
      'country': country,
    };
  }
}
