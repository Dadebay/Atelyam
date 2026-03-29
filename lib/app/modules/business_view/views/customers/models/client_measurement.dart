import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ClientMeasurement {
  final int id;
  final int? typeId; // measurement_type id - eşleştirme için
  final String label; // fallback (tm)
  final String? labelEn;
  final String? labelRu;
  final String? labelCh;
  final String? labelUz;
  final String? labelTr;
  final String value;

  const ClientMeasurement({
    required this.id,
    this.typeId,
    required this.label,
    this.labelEn,
    this.labelRu,
    this.labelCh,
    this.labelUz,
    this.labelTr,
    required this.value,
  });

  /// Uygulama diline göre doğru etiketi döndürür.
  String get localizedLabel {
    final String langCode = GetStorage().read('langCode') ?? Get.locale?.languageCode ?? 'tm';
    switch (langCode) {
      case 'en':
        return labelEn?.isNotEmpty == true ? labelEn! : label;
      case 'ru':
        return labelRu?.isNotEmpty == true ? labelRu! : label;
      case 'ch':
        return labelCh?.isNotEmpty == true ? labelCh! : label;
      case 'uz':
        return labelUz?.isNotEmpty == true ? labelUz! : label;
      case 'tr':
        return labelTr?.isNotEmpty == true ? labelTr! : label;
      default:
        return label;
    }
  }

  factory ClientMeasurement.fromJson(Map<String, dynamic> json) {
    final dynamic labelRaw = json['label'] ?? json['value_name'] ?? json['name'];
    final dynamic valueRaw = json['value'] ?? json['measurement'] ?? json['amount'];
    final rawValue = valueRaw?.toString() ?? '';
    final dynamic typeIdRaw = json['measurement_type'] ?? json['type_id'] ?? json['type'];
    final int recordId = (json['id'] as num?)?.toInt() ?? 0;
    final int? resolvedTypeId = typeIdRaw != null
        ? (typeIdRaw as num?)?.toInt()
        : recordId > 0
            ? recordId
            : null;
    return ClientMeasurement(
      id: recordId,
      typeId: resolvedTypeId,
      label: labelRaw?.toString() ?? '',
      labelEn: json['name_en'] as String?,
      labelRu: json['name_ru'] as String?,
      labelCh: json['name_ch'] as String?,
      labelUz: json['name_uz'] as String?,
      labelTr: json['name_tr'] as String?,
      value: (rawValue == 'null') ? '' : rawValue,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'value': value,
    };
  }
}
