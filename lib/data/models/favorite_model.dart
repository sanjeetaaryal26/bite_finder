class FavoriteModel {
  final String userId;
  final String restaurantId;

  const FavoriteModel({
    required this.userId,
    required this.restaurantId,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) => FavoriteModel(
        userId: json['userId'] as String,
        restaurantId: json['restaurantId'] as String,
      );

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'restaurantId': restaurantId,
      };
}
