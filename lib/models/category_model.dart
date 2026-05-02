class CategoryModel {
  final int categoryId;
  final String categoryName;

  const CategoryModel({
    required this.categoryId,
    required this.categoryName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      categoryId: json['category_id'] as int,
      categoryName: json['category_name'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'category_id': categoryId,
        'category_name': categoryName,
      };

  @override
  String toString() => categoryName;
}
