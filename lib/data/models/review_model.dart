class ReviewModel {
  final String id;
  final String restaurantId;
  final String userId;
  final int rating;
  final String comment;
  final String createdAt;

  const ReviewModel({
    required this.id,
    required this.restaurantId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        id: json['id'] as String,
        restaurantId: json['restaurantId'] as String,
        userId: json['userId'] as String,
        rating: json['rating'] as int,
        comment: json['comment'] as String,
        createdAt: json['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'restaurantId': restaurantId,
        'userId': userId,
        'rating': rating,
        'comment': comment,
        'createdAt': createdAt,
      };
}
