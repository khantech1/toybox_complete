class ToyImageModel {
  final int imageId;
  final int toyId;
  final String imageUrl;

  const ToyImageModel({
    required this.imageId,
    required this.toyId,
    required this.imageUrl,
  });

  factory ToyImageModel.fromJson(Map<String, dynamic> json) {
    return ToyImageModel(
      imageId: json['image_id'] as int,
      toyId: json['toy_id'] as int,
      imageUrl: json['image_url'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'image_id': imageId,
        'toy_id': toyId,
        'image_url': imageUrl,
      };
}
