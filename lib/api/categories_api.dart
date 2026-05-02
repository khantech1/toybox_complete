import '../models/category_model.dart';
import '../utils/constants.dart';
import 'api_client.dart';

class CategoriesApi {
  CategoriesApi._();

  static Future<List<CategoryModel>> getAll() async {
    final data = await ApiClient.get(AppConstants.categories);
    return (data as List)
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
