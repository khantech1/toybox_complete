import 'exchange_request_toy_model.dart';
import 'user_model.dart';

/// status: 'pending' | 'accepted' | 'declined' | 'completed'
class ExchangeRequestModel {
  final int requestId;
  final int initiatorUserId;
  final String status;
  final DateTime createdAt;
  final String? message;

  // Nested data
  final UserModel? initiator;
  final List<ExchangeRequestToyModel> toys;

  const ExchangeRequestModel({
    required this.requestId,
    required this.initiatorUserId,
    required this.status,
    required this.createdAt,
    this.message,
    this.initiator,
    this.toys = const [],
  });

  factory ExchangeRequestModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestModel(
      requestId: json['request_id'] as int,
      initiatorUserId: json['initiator_user_id'] as int,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      message: json['message'] as String?,
      initiator: json['initiator'] != null
          ? UserModel.fromJson(json['initiator'] as Map<String, dynamic>)
          : null,
      toys: json['toys'] != null
          ? (json['toys'] as List)
              .map((e) => ExchangeRequestToyModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
        'initiator_user_id': initiatorUserId,
        'status': status,
        'created_at': createdAt.toIso8601String(),
        'message': message,
      };

  bool get isPending => status == 'pending';
  bool get isAccepted => status == 'accepted';
  bool get isCompleted => status == 'completed';
  bool get isDeclined => status == 'declined';

  List<ExchangeRequestToyModel> get requestedToys =>
      toys.where((t) => t.isRequested).toList();

  List<ExchangeRequestToyModel> get offeredToys =>
      toys.where((t) => t.isOffered).toList();
}
