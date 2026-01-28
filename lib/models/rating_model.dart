class RatingModel {
  final String id;
  final String userId;
  final String apartmentId;
  final double rating;
  final String? comment;
  final DateTime createdAt;

  RatingModel({
    required this.id,
    required this.userId,
    required this.apartmentId,
    required this.rating,
    this.comment,
    required this.createdAt,
  });

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      apartmentId: json['apartment_id'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'apartment_id': apartmentId,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
