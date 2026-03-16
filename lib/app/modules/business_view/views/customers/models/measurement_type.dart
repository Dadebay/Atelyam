import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class MeasurementType {
  final int id;
  final String name;
  final String? nameEn;
  final String? nameRu;
  final String? nameCh;
  final String? nameUz;
  final String? nameTr;

  const MeasurementType({
    required this.id,
    required this.name,
    this.nameEn,
    this.nameRu,
    this.nameCh,
    this.nameUz,
    this.nameTr,
  });

  /// Uygulama diline göre doğru ismi döndürür.
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

  factory MeasurementType.fromJson(Map<String, dynamic> json) {
    return MeasurementType(
      id: (json['id'] as num).toInt(),
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en'] as String?,
      nameRu: json['name_ru'] as String?,
      nameCh: json['name_ch'] as String?,
      nameUz: json['name_uz'] as String?,
      nameTr: json['name_tr'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'name_en': nameEn,
      'name_ru': nameRu,
      'name_ch': nameCh,
      'name_uz': nameUz,
      'name_tr': nameTr,
    };
  }
}
