import 'dart:io';
import '../models/toy_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class ToysApi {
  ToysApi._();

  /// Get all toys (Toy Catalog). Optional filters.
  static Future<List<ToyModel>> getAll({
    String? search,
    int? categoryId,
    String? ageGroup,
  }) async {
    final params = <String, String>{};
    if (search != null && search.isNotEmpty) params['search'] = search;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (ageGroup != null && ageGroup.isNotEmpty) params['age_group'] = ageGroup;

    final data = await ApiClient.get(AppConstants.toys, params: params);
    return (data as List)
        .map((e) => ToyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Get a single toy by ID (detail page)
  static Future<ToyModel> getById(int toyId) async {
    final data = await ApiClient.get('${AppConstants.toys}/$toyId');
    return ToyModel.fromJson(data as Map<String, dynamic>);
  }

  /// Get current user's toys (for profile & exchange offer selection)
  static Future<List<ToyModel>> getMyToys() async {
    final data = await ApiClient.get(AppConstants.myToys);
    return (data as List)
        .map((e) => ToyModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new toy listing
  static Future<ToyModel> create({
    required String toyName,
    String? toyDescription,
    int? categoryId,
    int? desiredCategoryId,
    int? conditionStatus,
    double? value,
    List<int>? visibleToUserIds,
    bool visibleToAll = true,
  }) async {
    final body = <String, dynamic>{
      'toy_name': toyName,
      'toy_description': toyDescription,
      'category_id': categoryId,
      'desired_category_id': desiredCategoryId,
      'condition_status': conditionStatus,
      'value': value,
      'visible_to_all': visibleToAll,
      'visible_to_user_ids': visibleToUserIds,
    };
    body.removeWhere((key, value) => value == null);
    final data = await ApiClient.post(AppConstants.toys, body);
    return ToyModel.fromJson(data['toy'] as Map<String, dynamic>);
  }

  /// Update a toy listing
  static Future<ToyModel> update({
    required int toyId,
    String? toyName,
    String? toyDescription,
    int? categoryId,
    int? desiredCategoryId,
    int? conditionStatus,
    double? value,
    List<int>? visibleToUserIds,
    bool? visibleToAll,
  }) async {
    final body = <String, dynamic>{
      'toyName': toyName,
      'toyDescription': toyDescription,
      'categoryId': categoryId,
      'desiredCategoryId': desiredCategoryId,
      'conditionStatus': conditionStatus,
      'value': value,
      'visibleToAll': visibleToAll,
      'visibleToUserIds': visibleToUserIds,
    };

    body.removeWhere((key, value) => value == null);

    final data = await ApiClient.put('${AppConstants.toys}/$toyId', body);
    return ToyModel.fromJson(data['toy'] as Map<String, dynamic>);
  }

  /// Delete a toy
  static Future<void> delete(int toyId) async {
    await ApiClient.delete('${AppConstants.toys}/$toyId');
  }

  /// Upload toy images (up to 5)
  static Future<ToyModel> uploadImages(int toyId, List<File> images) async {
    // Upload images one by one (or backend can accept multiple)
    dynamic data;
    for (final img in images) {
      data = await ApiClient.uploadFile(
        '${AppConstants.toys}/$toyId/images',
        'image',
        img,
        {'toy_id': toyId.toString()},
      );
    }
    return ToyModel.fromJson(data['toy'] as Map<String, dynamic>);
  }
}
