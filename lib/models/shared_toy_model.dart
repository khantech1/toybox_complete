import 'user_model.dart';
import 'toy_model.dart';

class SharedToyModel {
  final int sharedWithUserId;
  final int toyId;
  final UserModel? sharedWithUser;
  final ToyModel? toy;

  const SharedToyModel({
    required this.sharedWithUserId,
    required this.toyId,
    this.sharedWithUser,
    this.toy,
  });

  factory SharedToyModel.fromJson(Map<String, dynamic> json) {
    return SharedToyModel(
      sharedWithUserId: json['shared_with_user_id'] as int,
      toyId: json['toy_id'] as int,
      sharedWithUser: json['shared_with_user'] != null
          ? UserModel.fromJson(json['shared_with_user'] as Map<String, dynamic>)
          : null,
      toy: json['toy'] != null
          ? ToyModel.fromJson(json['toy'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'shared_with_user_id': sharedWithUserId,
        'toy_id': toyId,
      };
}
