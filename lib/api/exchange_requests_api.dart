import '../models/exchange_request_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class ExchangeRequestsApi {
  ExchangeRequestsApi._();

  /// Get all requests for the current user (pending + completed)
  static Future<List<ExchangeRequestModel>> getAll({String? status}) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    final data = await ApiClient.get(AppConstants.exchangeRequests, params: params);
    return (data as List)
        .map((e) => ExchangeRequestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single exchange request by ID
  static Future<ExchangeRequestModel> getById(int requestId) async {
    final data = await ApiClient.get(
      '${AppConstants.exchangeRequests}/$requestId',
    );
    return ExchangeRequestModel.fromJson(data as Map<String, dynamic>);
  }

  /// Create a new exchange request
  /// requestedToyId: the toy being requested
  /// offeredToyId: the toy being offered in return
  static Future<ExchangeRequestModel> create({
    required int requestedToyId,
    required int offeredToyId,
    String? message,
  }) async {
    final data = await ApiClient.post(
      AppConstants.exchangeRequests,
      {
        'requested_toy_id': requestedToyId,
        'offered_toy_id': offeredToyId,
        if (message != null && message.isNotEmpty) 'message': message,
      },
    );
    return ExchangeRequestModel.fromJson(
      data['exchange_request'] as Map<String, dynamic>,
    );
  }

  /// Accept an exchange request
  static Future<ExchangeRequestModel> accept(int requestId) async {
    final data = await ApiClient.put(
      '${AppConstants.exchangeRequests}/$requestId/accept',
      {},
    );
    return ExchangeRequestModel.fromJson(
      data['exchange_request'] as Map<String, dynamic>,
    );
  }

  /// Decline an exchange request
  static Future<ExchangeRequestModel> decline(int requestId) async {
    final data = await ApiClient.put(
      '${AppConstants.exchangeRequests}/$requestId/decline',
      {},
    );
    return ExchangeRequestModel.fromJson(
      data['exchange_request'] as Map<String, dynamic>,
    );
  }
}
