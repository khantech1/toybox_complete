import 'toy_image_model.dart';
import 'category_model.dart';
import 'user_model.dart';

class ToyModel {
  final int toyId;
  final int ownerUserId;
  final String toyName;
  final String? toyDescription;
  final int? categoryId;
  final int? desiredCategoryId;
  final int? conditionStatus;
  final double? value;

  // Nested / joined data returned by the API
  final UserModel? owner;
  final CategoryModel? category;
  final CategoryModel? desiredCategory;
  final List<ToyImageModel> images;

  const ToyModel({
    required this.toyId,
    required this.ownerUserId,
    required this.toyName,
    this.toyDescription,
    this.categoryId,
    this.desiredCategoryId,
    this.conditionStatus,
    this.value,
    this.owner,
    this.category,
    this.desiredCategory,
    this.images = const [],
  });

  factory ToyModel.fromJson(Map<String, dynamic> json) {
    return ToyModel(
      toyId: json['toy_id'] as int,
      ownerUserId: json['owner_user_id'] as int,
      toyName: json['toy_name'] as String,
      toyDescription: json['toy_description'] as String?,
      categoryId: json['category_id'] as int?,
      desiredCategoryId: json['desired_category_id'] as int?,
      conditionStatus: json['condition_status'] as int?,
      value: json['value'] != null ? (json['value'] as num).toDouble() : null,
      owner: json['owner'] != null
          ? UserModel.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      desiredCategory: json['desired_category'] != null
          ? CategoryModel.fromJson(json['desired_category'] as Map<String, dynamic>)
          : null,
      images: json['images'] != null
          ? (json['images'] as List)
              .map((e) => ToyImageModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'toy_id': toyId,
        'owner_user_id': ownerUserId,
        'toy_name': toyName,
        'toy_description': toyDescription,
        'category_id': categoryId,
        'desired_category_id': desiredCategoryId,
        'condition_status': conditionStatus,
        'value': value,
      };

  String? get primaryImageUrl => images.isNotEmpty ? images.first.imageUrl : null;
}
