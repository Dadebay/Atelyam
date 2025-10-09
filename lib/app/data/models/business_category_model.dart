// lib/app/data/models/category_model.dart

class BusinessCategoryModel {
  final int id;
  final String name;
  final int place;
  final String created;
  final String img;

  BusinessCategoryModel({
    required this.id,
    required this.name,
    required this.place,
    required this.created,
    required this.img,
  });

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryModel(
      id: json['id'] ?? 0,
      name: json['name'].toString(),
      place: json['place'] ?? 0,
      created: json['created'].toString(),
      img: json['img'] != null ? json['img'].toString() : '',
    );
  }
}
