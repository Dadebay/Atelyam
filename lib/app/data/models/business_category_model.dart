// lib/app/data/models/business_category_model.dart

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class BusinessCategoryModel {
  final int id;
  final String name;
  final String? nameEn;
  final String? nameRu;
  final String? nameCh;
  final String? nameUz;
  final String? nameTr;
  final int place;
  final String created;
  final String img;

  BusinessCategoryModel({
    required this.id,
    required this.name,
    required this.place,
    required this.created,
    required this.img,
    this.nameEn,
    this.nameRu,
    this.nameCh,
    this.nameUz,
    this.nameTr,
  });

  /// Uygulama diline göre doğru ismi döndürür.
  /// Get.locale yerine GetStorage'dan okur — daha güvenilir.
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

  factory BusinessCategoryModel.fromJson(Map<String, dynamic> json) {
    return BusinessCategoryModel(
      id: json['id'] ?? 0,
      name: json['name']?.toString() ?? '',
      place: json['place'] ?? 0,
      created: json['created'].toString(),
      img: json['img'] != null ? json['img'].toString() : '',
      nameEn: json['name_en'] as String?,
      nameRu: json['name_ru'] as String?,
      nameCh: json['name_ch'] as String?,
      nameUz: json['name_uz'] as String?,
      nameTr: json['name_tr'] as String?,
    );
  }
}
