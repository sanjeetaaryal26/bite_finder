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
  final double mockDistanceKm;

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
    required this.mockDistanceKm,
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
      mockDistanceKm: mockDistanceKm,
    );
  }

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
        mockDistanceKm: (json['mockDistanceKm'] as num).toDouble(),
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
        'mockDistanceKm': mockDistanceKm,
      };
}
