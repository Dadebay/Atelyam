//lib/app/data/models/about_model.dart
class AboutModel {
  final int id;
  final String description;

  AboutModel({
    required this.id,
    required this.description,
  });

  factory AboutModel.fromJson(Map<String, dynamic> json) {
    return AboutModel(
      id: json['id'] as int,
      description: json['description'] as String,
    );
  }
}
