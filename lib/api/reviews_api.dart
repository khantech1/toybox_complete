import '../models/review_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class ReviewsApi {
  ReviewsApi._();

  /// Submit a review after a completed exchange
  static Future<ReviewModel> create({
    required int requestId,
    required int revieweeUserId,
    required int ratingScore,
    String? description,
  }) async {
    final data = await ApiClient.post(
      AppConstants.reviews,
      {
        'request_id': requestId,
        'reviewee_user_id': revieweeUserId,
        'rating_score': ratingScore,
        if (description != null && description.isNotEmpty)
          'description': description,
      },
    );
    return ReviewModel.fromJson(data['review'] as Map<String, dynamic>);
  }

  /// Get reviews written about a user
  static Future<List<ReviewModel>> getForUser(int userId) async {
    final data = await ApiClient.get(
      '${AppConstants.reviews}/user/$userId',
    );
    return (data as List)
        .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
