class CategoryModel {
  int id;
  String name;
  int count;
  String? logo;

  CategoryModel({
    required this.id,
    required this.name,
    required this.count,
    this.logo,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      count: json['count'],
      logo: json['logo'] == 'None' ? null : json['logo'],
    );
  }
}
