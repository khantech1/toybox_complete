import 'user_model.dart';

class ReviewModel {
  final int reviewId;
  final int requestId;
  final int reviewerUserId;
  final int revieweeUserId;
  final int ratingScore;
  final String? description;
  final DateTime createdAt;

  // Nested
  final UserModel? reviewer;
  final UserModel? reviewee;

  const ReviewModel({
    required this.reviewId,
    required this.requestId,
    required this.reviewerUserId,
    required this.revieweeUserId,
    required this.ratingScore,
    this.description,
    required this.createdAt,
    this.reviewer,
    this.reviewee,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      reviewId: json['review_id'] as int,
      requestId: json['request_id'] as int,
      reviewerUserId: json['reviewer_user_id'] as int,
      revieweeUserId: json['reviewee_user_id'] as int,
      ratingScore: json['rating_score'] as int,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      reviewer: json['reviewer'] != null
          ? UserModel.fromJson(json['reviewer'] as Map<String, dynamic>)
          : null,
      reviewee: json['reviewee'] != null
          ? UserModel.fromJson(json['reviewee'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'review_id': reviewId,
        'request_id': requestId,
        'reviewer_user_id': reviewerUserId,
        'reviewee_user_id': revieweeUserId,
        'rating_score': ratingScore,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };
}
