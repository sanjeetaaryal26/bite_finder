enum FeedbackType { feedback, complaint }

class FeedbackModel {
  final String id;
  final String userId;
  final String? restaurantId;
  final FeedbackType type;
  final String message;
  final String createdAt;

  const FeedbackModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.type,
    required this.message,
    required this.createdAt,
  });

  factory FeedbackModel.fromJson(Map<String, dynamic> json) => FeedbackModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        restaurantId: json['restaurantId'] as String?,
        type: (json['type'] as String) == 'complaint' ? FeedbackType.complaint : FeedbackType.feedback,
        message: json['message'] as String,
        createdAt: json['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'restaurantId': restaurantId,
        'type': type.name,
        'message': message,
        'createdAt': createdAt,
      };
}
