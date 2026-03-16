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

  // id-to-language mapping: 1=tm, 2=uz, 3=ru, 4=en, 5=tr, 6=ch
  static AboutModel? forLanguage(List<AboutModel> all, String langCode) {
    const Map<String, int> langToId = {
      'tm': 1,
      'uz': 2,
      'ru': 3,
      'en': 4,
      'tr': 5,
      'ch': 6,
    };
    final int? targetId = langToId[langCode] ?? langToId['tm'];
    try {
      return all.firstWhere((e) => e.id == targetId);
    } catch (_) {
      return all.isNotEmpty ? all.first : null;
    }
  }
}
