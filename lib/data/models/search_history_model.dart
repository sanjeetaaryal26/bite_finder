class SearchHistoryModel {
  final String id;
  final String userId;
  final String query;
  final String createdAt;

  const SearchHistoryModel({
    required this.id,
    required this.userId,
    required this.query,
    required this.createdAt,
  });

  factory SearchHistoryModel.fromJson(Map<String, dynamic> json) => SearchHistoryModel(
        id: json['id'] as String,
        userId: json['userId'] as String,
        query: json['query'] as String,
        createdAt: json['createdAt'] as String,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'query': query,
        'createdAt': createdAt,
      };
}
