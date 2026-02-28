import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class CategoryModel {
  int id;
  String name;
  String? nameEn;
  String? nameRu;
  String? nameCh;
  String? nameUz;
  String? nameTr;
  int count;
  String? logo;

  CategoryModel({
    required this.id,
    required this.name,
    required this.count,
    this.logo,
    this.nameEn,
    this.nameRu,
    this.nameCh,
    this.nameUz,
    this.nameTr,
  });

  /// Uygulama diline göre doğru ismi döndürür.
  /// GetStorage'dan okur — daha güvenilir.
  String get localizedName {
    final String langCode = GetStorage().read('langCode') ?? Get.locale?.languageCode ?? 'tm';
    switch (langCode) {
      case 'en':
        return nameEn?.isNotEmpty == true ? nameEn! : name;
      case 'ru':
        return nameRu?.isNotEmpty == true ? nameRu! : name;
      case 'ch':
        return nameCh?.isNotEmpty == true ? nameCh! : name;
      case 'uz':
        return nameUz?.isNotEmpty == true ? nameUz! : name;
      case 'tr':
        return nameTr?.isNotEmpty == true ? nameTr! : name;
      default:
        return name;
    }
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'] ?? '',
      count: json['count'] ?? 0,
      logo: json['logo'] == 'None' || json['logo'] == null ? null : json['logo'],
      nameEn: json['name_en'] as String?,
      nameRu: json['name_ru'] as String?,
      nameCh: json['name_ch'] as String?,
      nameUz: json['name_uz'] as String?,
      nameTr: json['name_tr'] as String?,
    );
  }
}
