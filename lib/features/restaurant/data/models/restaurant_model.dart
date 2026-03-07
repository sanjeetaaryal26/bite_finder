import 'dart:math' as math;

class RestaurantModel {
  final String id;
  final String name;
  final List<String> cuisines;
  final String location;
  final String description;
  final List<String> specialties;
  final List<String> services;
  final double ratingAvg;
  final int ratingCount;
  final String priceRange;
  final List<String> photos;
  final List<String> bestSellers;
  final double? latitude;
  final double? longitude;

  const RestaurantModel({
    required this.id,
    required this.name,
    required this.cuisines,
    required this.location,
    required this.description,
    required this.specialties,
    required this.services,
    required this.ratingAvg,
    required this.ratingCount,
    required this.priceRange,
    required this.photos,
    required this.bestSellers,
    required this.latitude,
    required this.longitude,
  });

  RestaurantModel copyWith({
    double? ratingAvg,
    int? ratingCount,
  }) {
    return RestaurantModel(
      id: id,
      name: name,
      cuisines: cuisines,
      location: location,
      description: description,
      specialties: specialties,
      services: services,
      ratingAvg: ratingAvg ?? this.ratingAvg,
      ratingCount: ratingCount ?? this.ratingCount,
      priceRange: priceRange,
      photos: photos,
      bestSellers: bestSellers,
      latitude: latitude,
      longitude: longitude,
    );
  }

  double? distanceFrom({
    required double userLatitude,
    required double userLongitude,
  }) {
    if (latitude == null || longitude == null) {
      return null;
    }
    return _haversineKm(
      lat1: userLatitude,
      lon1: userLongitude,
      lat2: latitude!,
      lon2: longitude!,
    );
  }

  static double _haversineKm({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(lat2 - lat1);
    final dLon = _degToRad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat1)) * math.cos(_degToRad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _degToRad(double degrees) => degrees * (math.pi / 180.0);

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
        id: json['id'] as String,
        name: json['name'] as String,
        cuisines: List<String>.from(json['cuisines'] as List),
        location: json['location'] as String,
        description: json['description'] as String,
        specialties: List<String>.from(json['specialties'] as List),
        services: List<String>.from(json['services'] as List),
        ratingAvg: (json['ratingAvg'] as num).toDouble(),
        ratingCount: json['ratingCount'] as int,
        priceRange: json['priceRange'] as String,
        photos: List<String>.from(json['photos'] as List),
        bestSellers: List<String>.from(json['bestSellers'] as List),
        latitude: (json['latitude'] as num?)?.toDouble(),
        longitude: (json['longitude'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'cuisines': cuisines,
        'location': location,
        'description': description,
        'specialties': specialties,
        'services': services,
        'ratingAvg': ratingAvg,
        'ratingCount': ratingCount,
        'priceRange': priceRange,
        'photos': photos,
        'bestSellers': bestSellers,
        'latitude': latitude,
        'longitude': longitude,
      };
}
