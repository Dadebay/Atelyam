//lib/app/data/models/banner_model.dart
class BannerModel {
  final int id;
  final String img;
  final String description;

  BannerModel({
    required this.id,
    required this.img,
    required this.description,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      img: json['img'] as String,
      description: json['description'] as String,
    );
  }
}
