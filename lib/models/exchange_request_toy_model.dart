import 'toy_model.dart';

/// exchange_role: 'offered' | 'requested'
class ExchangeRequestToyModel {
  final int requestId;
  final int toyId;
  final String exchangeRole;
  final ToyModel? toy;

  const ExchangeRequestToyModel({
    required this.requestId,
    required this.toyId,
    required this.exchangeRole,
    this.toy,
  });

  factory ExchangeRequestToyModel.fromJson(Map<String, dynamic> json) {
    return ExchangeRequestToyModel(
      requestId: json['request_id'] as int,
      toyId: json['toy_id'] as int,
      exchangeRole: json['exchange_role'] as String,
      toy: json['toy'] != null
          ? ToyModel.fromJson(json['toy'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'request_id': requestId,
        'toy_id': toyId,
        'exchange_role': exchangeRole,
      };

  bool get isOffered => exchangeRole == 'offered';
  bool get isRequested => exchangeRole == 'requested';
}
